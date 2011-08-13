//
//  PTTargetActionEventListener.m
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTTargetActionEventListener.h"


@implementation PTTargetActionEventListener

- (id)initWithTarget:(id)aTarget action:(SEL)aSelector
{
  if (self = [super init]) {
    target = [aTarget retain];
    action = aSelector;
  }
  return self;
}

- (void)dealloc;
{
  [target release];
  [super dealloc];
}

- (NSString *)description;
{
  return [NSString stringWithFormat:@"<PTEventListener target:%@ selector:%@>", target, NSStringFromSelector(action)];
}

- (void)dispatchEvent:(PTPusherEvent *)event;
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [target performSelector:action withObject:event];
  });
}

@end

@implementation PTPusherEventDispatcher (PTTargetActionFactory)

- (void)addEventListenerForEventNamed:(NSString *)eventName target:(id)target action:(SEL)action
{
  PTTargetActionEventListener *listener = [[PTTargetActionEventListener alloc] initWithTarget:target action:action];
  [self addEventListener:listener forEventNamed:eventName];
  [listener release];
}

@end
