//
//  PTPusherClient.m
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusherChannel.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherEventDispatcher.h"
#import "PTTargetActionEventListener.h"
#import "PTBlockEventListener.h"
#import "PTPusherChannelAuthorizationOperation.h"
#import "PTPusherErrors.h"


@interface PTPusherChannel ()
@property (nonatomic, assign, readwrite) BOOL subscribed;
@end

#pragma mark -

@implementation PTPusherChannel

@synthesize name;
@synthesize subscribed;

+ (id)channelWithName:(NSString *)name pusher:(PTPusher *)pusher
{
  if ([name hasPrefix:@"private-"]) {
    return [[[PTPusherPrivateChannel alloc] initWithName:name pusher:pusher] autorelease];
  }
  if ([name hasPrefix:@"presence-"]) {
    return [[[PTPusherPresenceChannel alloc] initWithName:name pusher:pusher] autorelease];
  }
  return [[[self alloc] initWithName:name pusher:pusher] autorelease];
}

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)aPusher
{
  if (self = [super init]) {
    name = [channelName copy];
    pusher = aPusher;
    dispatcher = [[PTPusherEventDispatcher alloc] init];
  }
  return self;
}

- (void)dealloc;
{
  [name release];
  [dispatcher release];
  [super dealloc];
}

- (BOOL)isPrivate
{
  return NO;
}

- (BOOL)isPresence
{
  return NO;
}

#pragma mark - Authorization

- (void)authorizeWithCompletionHandler:(void(^)(BOOL, NSDictionary *))completionHandler
{
  completionHandler(YES, [NSDictionary dictionary]); // public channels do not require authorization
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

#pragma mark - Dispatching events

- (void)dispatchEvent:(PTPusherEvent *)event
{
  [dispatcher dispatchEvent:event];
  
  [[NSNotificationCenter defaultCenter] 
       postNotificationName:PTPusherEventReceivedNotification 
                     object:self 
                   userInfo:[NSDictionary dictionaryWithObject:event forKey:PTPusherEventUserInfoKey]];
}

#pragma mark - Internal use only

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  if (self.isSubscribed) return;
  
  [pusher sendEventNamed:@"pusher:subscribe" 
                    data:[NSDictionary dictionaryWithObject:self.name forKey:@"channel"]
                 channel:nil];
  
  self.subscribed = YES;
}

- (void)unsubscribe
{
  [pusher sendEventNamed:@"pusher:unsubscribe" 
                    data:[NSDictionary dictionaryWithObject:self.name forKey:@"channel"]
                 channel:nil];
  
  self.subscribed = NO;
  
  if ([pusher.delegate respondsToSelector:@selector(pusher:didUnsubscribeFromChannel:)]) {
    [pusher.delegate pusher:pusher didUnsubscribeFromChannel:self];
  }
}

- (void)markAsUnsubscribed
{
  self.subscribed = NO;
}

@end

#pragma mark -

@implementation PTPusherPrivateChannel

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)aPusher
{
  if ((self = [super initWithName:channelName pusher:aPusher])) {
    
    /* Set up event handlers for pre-defined channel events */
    
    [pusher bindToEventNamed:@"pusher_internal:subscription_succeeded" 
                      target:self action:@selector(handleSubscribeEvent:)];  
    
    [pusher bindToEventNamed:@"subscription_error" 
                      target:self action:@selector(handleSubscribeErrorEvent:)];
  }
  return self;
}

- (BOOL)isPrivate
{
  return YES;
}

- (void)handleSubscribeEvent:(PTPusherEvent *)event
{
  self.subscribed = YES;
  
  if ([pusher.delegate respondsToSelector:@selector(pusher:didSubscribeToChannel:)]) {
    [pusher.delegate pusher:pusher didSubscribeToChannel:self];
  }
}

- (void)handleSubcribeErrorEvent:(PTPusherEvent *)event
{
  if ([pusher.delegate respondsToSelector:@selector(pusher:didFailToSubscribeToChannel:withError:)]) {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:PTPusherErrorUnderlyingEventKey];
    NSError *error = [NSError errorWithDomain:PTPusherErrorDomain code:PTPusherSubscriptionError userInfo:userInfo];
    [pusher.delegate pusher:pusher didFailToSubscribeToChannel:self withError:error];
  }
}

- (void)authorizeWithCompletionHandler:(void(^)(BOOL, NSDictionary *))completionHandler
{
  PTPusherChannelAuthorizationOperation *authOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:pusher.authorizationURL channelName:self.name socketID:pusher.connection.socketID];
  
  [authOperation setCompletionHandler:^(PTPusherChannelAuthorizationOperation *operation) {
    completionHandler(operation.isAuthorized, operation.authorizationData);
  }];
  
  if ([pusher.delegate respondsToSelector:@selector(pusher:willAuthorizeChannelWithRequest:)]) {
    [pusher.delegate pusher:pusher willAuthorizeChannelWithRequest:authOperation.mutableURLRequest];
  }
  
  [[NSOperationQueue mainQueue] addOperation:authOperation];
}

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  if (self.isSubscribed) return;
  
  NSMutableDictionary *eventData = [[authData mutableCopy] autorelease];
  [eventData setObject:self.name forKey:@"channel"];
  [pusher sendEventNamed:@"pusher:subscribe" 
                    data:eventData
                 channel:nil];
}

#pragma mark - Triggering events

- (void)triggerEventNamed:(NSString *)eventName data:(id)eventData
{
  [pusher sendEventNamed:eventName data:eventData channel:self.name];
}

@end

#pragma mark -

@implementation PTPusherPresenceChannel

@synthesize presenceDelegate;
@synthesize members;

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)aPusher
{
  if ((self = [super initWithName:channelName pusher:aPusher])) {
    members = [[NSMutableDictionary alloc] init];
    memberIDs = [[NSMutableArray alloc] init];
    
    /* Set up event handlers for pre-defined channel events */

    [pusher bindToEventNamed:@"pusher_internal:member_added" 
                      target:self action:@selector(handleMemberAddedEvent:)];
    
    [pusher bindToEventNamed:@"pusher_internal:member_removed" 
                      target:self action:@selector(handleMemberRemovedEvent:)];
    
  }
  return self;
}

- (void)handleSubscribeEvent:(PTPusherEvent *)event
{
  NSDictionary *presenceData = [event.data objectForKey:@"presence"];
  [super handleSubscribeEvent:event];
  [members setDictionary:[presenceData objectForKey:@"hash"]];
  [memberIDs setArray:[presenceData objectForKey:@"ids"]];
  [self.presenceDelegate presenceChannel:self didSubscribeWithMemberList:memberIDs];
}

- (BOOL)isPresence
{
  return YES;
}

- (NSDictionary *)infoForMemberWithID:(NSString *)memberID
{
  return [members objectForKey:memberID];
}

- (NSArray *)memberIDs
{
  return [[memberIDs copy] autorelease];
}

- (NSInteger)memberCount
{
  return [memberIDs count];
}

- (void)dealloc 
{
  [members release];
  [memberIDs release];
  [super dealloc];
}

- (void)handleMemberAddedEvent:(PTPusherEvent *)event
{
  [memberIDs addObject:[event.data objectForKey:@"user_id"]];
  [members setObject:[event.data objectForKey:@"user_info"] 
              forKey:[event.data objectForKey:@"user_id"]];
  [self.presenceDelegate presenceChannel:self memberAdded:event.data];
}

- (void)handleMemberRemovedEvent:(PTPusherEvent *)event
{
  [memberIDs removeObject:[event.data valueForKey:@"user_id"]];
  [members removeObjectForKey:[event.data valueForKey:@"user_id"]]; 
  [self.presenceDelegate presenceChannel:self memberRemoved:event.data];
}

@end

