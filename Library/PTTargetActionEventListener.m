//
//  PTTargetActionEventListener.m
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTTargetActionEventListener.h"


@implementation PTTargetActionEventListener {
  BOOL _invalid;
}

- (id)initWithTarget:(id)aTarget action:(SEL)aSelector
{
  if (self = [super init]) {
    target = aTarget;
    action = aSelector;
    _invalid = NO;
  }
  return self;
}

- (void)invalidate
{
  _invalid = YES;
}

- (NSString *)description;
{
  return [NSString stringWithFormat:@"<PTEventListener target:%@ selector:%@>", target, NSStringFromSelector(action)];
}

- (void)dispatchEvent:(PTPusherEvent *)event;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  if (!_invalid) {
    [target performSelector:action withObject:event];
  }
#pragma clang diagnostic pop
}

@end

@implementation PTPusherEventDispatcher (PTTargetActionFactory)

- (PTPusherEventBinding *)addEventListenerForEventNamed:(NSString *)eventName target:(id)target action:(SEL)action
{
  PTTargetActionEventListener *listener = [[PTTargetActionEventListener alloc] initWithTarget:target action:action];
  return [self addEventListener:listener forEventNamed:eventName];
}

@end
