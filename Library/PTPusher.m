//
//  PTPusher.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusher.h"
#import "PTEventListener.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "PTPusherEventDispatcher.h"
#import "PTTargetActionEventListener.h"
#import "PTBlockEventListener.h"
#import "PTPusherErrors.h"
#import "PTPusherChannelAuthorizationOperation.h"

#define kPUSHER_HOST @"ws.pusherapp.com"

NSURL *PTPusherConnectionURL(NSString *host, NSString *key, NSString *clientID, BOOL secure);

NSString *const PTPusherEventReceivedNotification = @"PTPusherEventReceivedNotification";
NSString *const PTPusherEventUserInfoKey          = @"PTPusherEventUserInfoKey";
NSString *const PTPusherErrorDomain               = @"PTPusherErrorDomain";
NSString *const PTPusherErrorUnderlyingEventKey   = @"PTPusherErrorUnderlyingEventKey";

NSURL *PTPusherConnectionURL(NSString *host, NSString *key, NSString *clientID, BOOL encrypted)
{
  NSString *scheme = ((encrypted == YES) ? @"wss" : @"ws");
  NSString *URLString = [NSString stringWithFormat:@"%@://%@/app/%@?client=%@&protocol=%d&version=%f", 
                         scheme, host, key, clientID, kPTPusherClientProtocolVersion, kPTPusherClientLibraryVersion];
  return [NSURL URLWithString:URLString];
}

#define kPTPusherDefaultReconnectDelay 5.0

@interface PTPusher ()
@property (nonatomic, strong, readwrite) PTPusherConnection *connection;

- (void)subscribeToChannel:(PTPusherChannel *)channel;
- (void)reconnectAfterDelay;
@end

@interface PTPusherChannel ()
/* These methods should only be called internally */
- (void)subscribeWithAuthorization:(NSDictionary *)authData;
- (void)unsubscribe;
- (void)markAsUnsubscribed;
@end

#pragma mark -

@implementation PTPusher {
  NSOperationQueue *authorizationQueue;
}

@synthesize connection = _connection;
@synthesize delegate;
@synthesize reconnectAutomatically;
@synthesize reconnectDelay;
@synthesize authorizationURL;

- (id)initWithConnection:(PTPusherConnection *)connection connectAutomatically:(BOOL)connectAutomatically
{
  if (self = [super init]) {
    dispatcher = [[PTPusherEventDispatcher alloc] init];
    channels = [[NSMutableDictionary alloc] init];
    
    authorizationQueue = [[NSOperationQueue alloc] init];
    authorizationQueue.maxConcurrentOperationCount = 5;
    authorizationQueue.name = @"com.pusher.libPusher.authorizationQueue";
    
    self.connection = connection;
    self.connection.delegate = self;
    
    self.reconnectAutomatically = NO;
    self.reconnectDelay = kPTPusherDefaultReconnectDelay;
    
    if (connectAutomatically) {
      [self connect];
    }
  }
  return self;
}

+ (id)pusherWithKey:(NSString *)key delegate:(id<PTPusherDelegate>)delegate
{
  return [self pusherWithKey:key delegate:delegate encrypted:YES];
}

+ (id)pusherWithKey:(NSString *)key delegate:(id<PTPusherDelegate>)delegate encrypted:(BOOL)isEncrypted
{
  PTPusher *pusher = [self pusherWithKey:key connectAutomatically:NO encrypted:isEncrypted];
  pusher.delegate = delegate;
  [pusher connect];
  return pusher;
}

+ (id)pusherWithKey:(NSString *)key connectAutomatically:(BOOL)connectAutomatically
{
  return [self pusherWithKey:key connectAutomatically:connectAutomatically encrypted:YES];
}

+ (id)pusherWithKey:(NSString *)key connectAutomatically:(BOOL)connectAutomatically encrypted:(BOOL)isEncrypted
{
  NSURL *serviceURL = PTPusherConnectionURL(kPUSHER_HOST, key, @"libPusher", isEncrypted);
  PTPusherConnection *connection = [[PTPusherConnection alloc] initWithURL:serviceURL];
  PTPusher *pusher = [[self alloc] initWithConnection:connection connectAutomatically:connectAutomatically];
  return pusher;
}

- (void)dealloc;
{
  [_connection setDelegate:nil];
  [_connection disconnect];
}

#pragma mark - Connection management

- (void)connect
{
  [self.connection connect];
}

- (void)disconnect
{
  [self.connection disconnect];
}

#pragma mark - Binding to events

- (PTPusherEventBinding *)bindToEventNamed:(NSString *)eventName target:(id)target action:(SEL)selector
{
  return [dispatcher addEventListenerForEventNamed:eventName target:target action:selector];
}

- (PTPusherEventBinding *)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block
{
  return [self bindToEventNamed:eventName handleWithBlock:block queue:dispatch_get_main_queue()];
}

- (PTPusherEventBinding *)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block queue:(dispatch_queue_t)queue
{
  return [dispatcher addEventListenerForEventNamed:eventName block:block queue:queue];
}

- (void)removeBinding:(PTPusherEventBinding *)binding
{
  [dispatcher removeBinding:binding];
}

- (void)removeAllBindings
{
  [dispatcher removeAllBindings];
}

#pragma mark - Subscribing to channels

- (PTPusherChannel *)subscribeToChannelNamed:(NSString *)name
{
  PTPusherChannel *channel = [channels objectForKey:name];
  if (channel == nil) {
    channel = [PTPusherChannel channelWithName:name pusher:self]; 
    [channels setObject:channel forKey:name];
  }
  // private/presence channels require a socketID to authenticate
  if (self.connection.isConnected && self.connection.socketID) {
    [self subscribeToChannel:channel];
  }
  return channel;
}

- (PTPusherPrivateChannel *)subscribeToPrivateChannelNamed:(NSString *)name
{
  return (PTPusherPrivateChannel *)[self subscribeToChannelNamed:[NSString stringWithFormat:@"private-%@", name]];
}

- (PTPusherPresenceChannel *)subscribeToPresenceChannelNamed:(NSString *)name
{
  return (PTPusherPresenceChannel *)[self subscribeToChannelNamed:[NSString stringWithFormat:@"presence-%@", name]];
}

- (PTPusherPresenceChannel *)subscribeToPresenceChannelNamed:(NSString *)name delegate:(id<PTPusherPresenceChannelDelegate>)presenceDelegate
{
  PTPusherPresenceChannel *channel = [self subscribeToPresenceChannelNamed:name];
  channel.presenceDelegate = presenceDelegate;
  return channel;
}

- (PTPusherChannel *)channelNamed:(NSString *)name
{
  return [channels objectForKey:name];
}

- (void)__unsubscribeFromChannel:(PTPusherChannel *)channel
{
  NSParameterAssert(channel != nil);
  
  if (channel.isSubscribed == NO) return;
  
  [self sendEventNamed:@"pusher:unsubscribe" 
                  data:[NSDictionary dictionaryWithObject:channel.name forKey:@"channel"]];
  
  [channel removeAllBindings];
  [channel markAsUnsubscribed];
  
  if ([self.delegate respondsToSelector:@selector(pusher:didUnsubscribeFromChannel:)]) {
    [self.delegate pusher:self didUnsubscribeFromChannel:channel];
  }
  
  [channels removeObjectForKey:channel.name];
}

- (void)unsubscribeFromChannel:(PTPusherChannel *)channel
{
  [self __unsubscribeFromChannel:channel];
}

- (void)subscribeToChannel:(PTPusherChannel *)channel
{
  [channel authorizeWithCompletionHandler:^(BOOL isAuthorized, NSDictionary *authData, NSError *error) {
    if (isAuthorized && self.connection.isConnected) {
      [channel subscribeWithAuthorization:authData];
    }
    else {
      if (error == nil) {
        error = [NSError errorWithDomain:PTPusherErrorDomain code:PTPusherSubscriptionUnknownAuthorisationError userInfo:nil];
      }
      
      if ([self.delegate respondsToSelector:@selector(pusher:didFailToSubscribeToChannel:withError:)]) {
        [self.delegate pusher:self didFailToSubscribeToChannel:channel withError:error];
      }
    }
  }];
}

#pragma mark - Sending events

- (void)sendEventNamed:(NSString *)name data:(id)data
{
  [self sendEventNamed:name data:data channel:nil];
}

- (void)sendEventNamed:(NSString *)name data:(id)data channel:(NSString *)channelName
{
  NSParameterAssert(name);
  
  NSMutableDictionary *payload = [NSMutableDictionary dictionary];  
  [payload setObject:name forKey:PTPusherEventKey];
  
  if (data) {
    [payload setObject:data forKey:PTPusherDataKey];
  }
  
  if (channelName) {
    [payload setObject:channelName forKey:PTPusherChannelKey];
  }
  [self.connection send:payload];
}

#pragma mark - PTPusherConnection delegate methods

- (void)pusherConnectionDidConnect:(PTPusherConnection *)connection
{
  if ([self.delegate respondsToSelector:@selector(pusher:connectionDidConnect:)]) {
    [self.delegate pusher:self connectionDidConnect:connection];
  }
  
  for (PTPusherChannel *channel in [channels allValues]) {
    [self subscribeToChannel:channel];
  }
}

- (void)pusherConnection:(PTPusherConnection *)connection didDisconnectWithCode:(NSInteger)errorCode reason:(NSString *)reason wasClean:(BOOL)wasClean
{
  NSError *error = nil;
  
  if (errorCode > 0) {
    if (reason == nil) {
      reason = @"Unknown error"; // not sure what could cause this to be nil, but just playing it safe
    }
    error = [NSError errorWithDomain:PTPusherErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObject:reason forKey:@"reason"]];
  }
  
  [self handleDisconnection:connection error:error];
}

- (void)pusherConnection:(PTPusherConnection *)connection didFailWithError:(NSError *)error wasConnected:(BOOL)wasConnected
{
  if ([self.delegate respondsToSelector:@selector(pusher:connection:failedWithError:)]) {
    [self.delegate pusher:self connection:connection failedWithError:error];
  }
  if (wasConnected) {
    [self handleDisconnection:connection error:error];
  }
  else if(self.shouldReconnectAutomatically) {
    [self reconnectAfterDelay];
  }
}

- (void)pusherConnection:(PTPusherConnection *)connection didReceiveEvent:(PTPusherEvent *)event
{
  if ([event isKindOfClass:[PTPusherErrorEvent class]]) {
    if ([self.delegate respondsToSelector:@selector(pusher:didReceiveErrorEvent:)]) {
      [self.delegate pusher:self didReceiveErrorEvent:(PTPusherErrorEvent *)event];
    }
  }
  
  if (event.channel) {
    [[channels objectForKey:event.channel] dispatchEvent:event];
  }
  [dispatcher dispatchEvent:event];
  
  [[NSNotificationCenter defaultCenter] 
   postNotificationName:PTPusherEventReceivedNotification 
   object:self 
   userInfo:[NSDictionary dictionaryWithObject:event forKey:PTPusherEventUserInfoKey]];
}

- (void)handleDisconnection:(PTPusherConnection *)connection error:(NSError *)error
{
  [authorizationQueue cancelAllOperations];
  
  for (PTPusherChannel *channel in [channels allValues]) {
    [channel markAsUnsubscribed];
  }
  if ([self.delegate respondsToSelector:@selector(pusher:connectionDidDisconnect:)]) { // deprecated call
    [self.delegate pusher:self connectionDidDisconnect:connection];
  }
  if ([self.delegate respondsToSelector:@selector(pusher:connection:didDisconnectWithError:)]) {
    [self.delegate pusher:self connection:connection didDisconnectWithError:error];
  }
  if (self.shouldReconnectAutomatically) {
    [self reconnectAfterDelay]; 
  }
}

#pragma mark - Private

- (void)beginAuthorizationOperation:(PTPusherChannelAuthorizationOperation *)operation
{
  [authorizationQueue addOperation:operation];
}

- (void)reconnectAfterDelay
{
  if ([self.delegate respondsToSelector:@selector(pusher:connectionWillReconnect:afterDelay:)]) {
    [self.delegate pusher:self connectionWillReconnect:_connection afterDelay:self.reconnectDelay];
  }
  
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.reconnectDelay * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    if (self.reconnectAutomatically) { // check this hasn't been changed since we queued this block
      [_connection connect];
    }
  });
}

@end
