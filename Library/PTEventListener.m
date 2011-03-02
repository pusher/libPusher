//
//  PTEventListener.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTEventListener.h"


@implementation PTEventListener

- (id)initWithTarget:(id)_target selector:(SEL)_selector
{
	if ((self = [super init])) {
		target = [_target retain];
		selector = _selector;
	}
	return self;
}

- (id)initWithBlock:(PTPusherEventHandlerBlock)aBlock;
{
  if ((self = [super init])) {
    block = [aBlock copy];
  }
  return self;
}

- (void)dealloc
{
  [block release];
	[target release];
	[super dealloc];
}

- (NSString *)description
{
  if (block) {
    return @"<PTEventListener block>";
  }
	return [NSString stringWithFormat:@"<PTEventListener target:%@ selector:%@>", target, NSStringFromSelector(selector)];
}

- (void)dispatch:(PTPusherEvent *)event
{
  if (block) {
    block(event);
  } else {
    [target performSelector:selector withObject:event];
  }
}

@end
