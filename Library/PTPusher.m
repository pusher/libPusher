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


NSURL *PTPusherConnectionURL(NSString *host, int port, NSString *key, NSString *clientID);

NSString *const PTPusherEventReceivedNotification = @"PTPusherEventReceivedNotification";
NSString *const PTPusherEventUserInfoKey = @"PTPusherEventUserInfoKey";
NSString *const PTPusherErrorDomain = @"PTPusherErrorDomain";
NSString *const PTPusherErrorUnderlyingEventKey = @"PTPusherErrorUnderlyingEventKey";

NSURL *PTPusherConnectionURL(NSString *host, int port, NSString *key, NSString *clientID)
{
  NSString *URLString = [NSString stringWithFormat:@"ws://%@:%d/app/%@?client=%@", host, port, key, clientID];
  return [NSURL URLWithString:URLString];
}

#define kPTPusherDefaultReconnectDelay 5.0

@interface PTPusher ()
@property (nonatomic, retain, readwrite) PTPusherConnection *connection;

- (void)subscribeToChannel:(PTPusherChannel *)channel;
- (void)reconnectAfterDelay;
@end

@interface PTPusherChannel ()
/* These methods should only be called internally */
- (void)subscribeWithAuthorization:(NSDictionary *)authData;
- (void)unsubscribe;
@end

#pragma mark -

@implementation PTPusher

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
  PTPusher *pusher = [self pusherWithKey:key connectAutomatically:NO];
  pusher.delegate = delegate;
  [pusher connect];
  return pusher;
}

+ (id)pusherWithKey:(NSString *)key connectAutomatically:(BOOL)connectAutomatically
{
  PTPusherConnection *connection = [[PTPusherConnection alloc] initWithURL:PTPusherConnectionURL(@"ws.pusherapp.com", 443, key, @"libpusher") secure:YES];
  PTPusher *pusher = [[self alloc] initWithConnection:connection connectAutomatically:connectAutomatically];
  [connection release];
  return [pusher autorelease];
}

- (void)dealloc;
{
  [authorizationURL release];
  [channels release];
  [_connection disconnect];
  [_connection release];
  [super dealloc];
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

- (void)bindToEventNamed:(NSString *)eventName target:(id)target action:(SEL)selector
{
  [dispatcher addEventListenerForEventNamed:eventName target:target action:selector];
}

- (void)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block
{
  [self bindToEventNamed:eventName handleWithBlock:block queue:dispatch_get_main_queue()];
}

- (void)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block queue:(dispatch_queue_t)queue
{
  [dispatcher addEventListenerForEventNamed:eventName block:block queue:queue];
}

#pragma mark - Subscribing to channels

- (PTPusherChannel *)subscribeToChannelNamed:(NSString *)name
{
  PTPusherChannel *channel = [channels objectForKey:name];
  if (channel == nil) {
    channel = [PTPusherChannel channelWithName:name pusher:self]; 
    [channels setObject:channel forKey:name];
  }
  if (self.connection.isConnected) {
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

- (void)unsubscribeFromChannel:(PTPusherChannel *)channel
{
  [channel unsubscribe];
  [channels removeObjectForKey:channel.name];
}

- (void)subscribeToChannel:(PTPusherChannel *)channel
{
  [channel authorizeWithCompletionHandler:^(BOOL isAuthorized, NSDictionary *authData) {
    if (isAuthorized) {
      [channel subscribeWithAuthorization:authData];
    }
    else {
      NSError *error = [NSError errorWithDomain:PTPusherErrorDomain code:PTPusherSubscriptionAuthorisationError userInfo:nil];

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
  NSMutableDictionary *payload = [NSMutableDictionary dictionary];
  
  [payload setObject:name forKey:@"event"];
  [payload setObject:data forKey:@"data"];
  
  if (channelName) {
    [payload setObject:channelName forKey:@"channel"];
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

- (void)pusherConnectionDidDisconnect:(PTPusherConnection *)connection
{
  if ([self.delegate respondsToSelector:@selector(pusher:connectionDidDisconnect:)]) {
    [self.delegate pusher:self connectionDidDisconnect:connection];
  }
  if (self.shouldReconnectAutomatically) {
    [self reconnectAfterDelay]; 
  }
}

- (void)pusherConnection:(PTPusherConnection *)connection didFailWithError:(NSError *)error
{
  if ([self.delegate respondsToSelector:@selector(pusher:connection:failedWithError:)]) {
    [self.delegate pusher:self connection:connection failedWithError:error];
  }
  if ([error.domain isEqualToString:ZTWebSocketErrorDomain] && self.shouldReconnectAutomatically) {
    [self reconnectAfterDelay];
  }
}

- (void)pusherConnection:(PTPusherConnection *)connection didReceiveEvent:(PTPusherEvent *)event
{
  if (event.channel) {
    [[channels objectForKey:event.channel] dispatchEvent:event];
  }
  [dispatcher dispatchEvent:event];
  
  [[NSNotificationCenter defaultCenter] 
        postNotificationName:PTPusherEventReceivedNotification 
                      object:self 
                    userInfo:[NSDictionary dictionaryWithObject:event forKey:PTPusherEventUserInfoKey]];
}

#pragma mark - Private

- (void)reconnectAfterDelay
{
  if ([self.delegate respondsToSelector:@selector(pusher:connectionWillReconnect:afterDelay:)]) {
    [self.delegate pusher:self connectionWillReconnect:_connection afterDelay:self.reconnectDelay];
  }
  
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.reconnectDelay * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [_connection connect];
  });
}

@end
