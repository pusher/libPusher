//
//  PTEventListener.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTEventListener.h"


@implementation PTEventListener

- (id)initWithTarget:(id)_target selector:(SEL)_selector;
{
  if (self = [super init]) {
    target = [_target retain];
    selector = _selector;
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
  return [NSString stringWithFormat:@"<PTEventListener target:%@ selector:%@>", target, NSStringFromSelector(selector)];
}

- (void)dispatch:(id)eventData;
{
  [target performSelectorOnMainThread:selector withObject:eventData waitUntilDone:NO];
}

@end
