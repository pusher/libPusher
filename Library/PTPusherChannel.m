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
#import "JSON.h"
#import "NSString+Hashing.h"
#import "NSDictionary+QueryString.h"
#import "PTPusherEventDispatcher.h"
#import "PTTargetActionEventListener.h"

@implementation PTPusherChannel

@synthesize name;
@synthesize delegate;

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

#pragma mark - Binding to events

- (void)bindToEventNamed:(NSString *)eventName target:(id)target action:(SEL)selector
{
  [dispatcher addEventListenerForEventNamed:eventName target:target action:selector];
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

@end
