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


@implementation PTPusherChannel

@synthesize name;

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
}

#pragma mark - Triggering events

- (void)triggerEventNamed:(NSString *)eventName data:(id)eventData
{
  [pusher sendEventNamed:eventName data:eventData channel:self.name];
}

#pragma mark - Internal use only

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  [pusher sendEventNamed:@"pusher:subscribe" 
                    data:[NSDictionary dictionaryWithObject:self.name forKey:@"channel"]];
}

- (void)unsubscribe
{
  [pusher sendEventNamed:@"pusher:unsubscribe" 
                    data:[NSDictionary dictionaryWithObject:self.name forKey:@"channel"]];
}

@end

#pragma mark -

@implementation PTPusherPrivateChannel

- (void)authorizeWithCompletionHandler:(void(^)(BOOL, NSDictionary *))completionHandler
{
  PTPusherChannelAuthorizationOperation *authOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:pusher.authorizationURL channelName:self.name socketID:pusher.connection.socketID];
  
  [authOperation setCompletionHandler:^(PTPusherChannelAuthorizationOperation *operation) {
    completionHandler(operation.isAuthorized, operation.authorizationData);
  }];
  [[NSOperationQueue mainQueue] addOperation:authOperation];
}

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  NSMutableDictionary *eventData = [[authData mutableCopy] autorelease];
  [eventData setObject:self.name forKey:@"channel"];
  [pusher sendEventNamed:@"pusher:subscribe" 
                    data:eventData];
}

@end

#pragma mark -

@implementation PTPusherPresenceChannel

@end

