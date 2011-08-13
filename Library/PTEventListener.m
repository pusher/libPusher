//
//  PTEventListener.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTEventListener.h"


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

- (void)dispatch:(PTPusherEvent *)event;
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [target performSelector:action withObject:event];
  });
}

@end
