//
//  PTPusherEvent.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusherEvent.h"


@implementation PTPusherEvent

@synthesize name, data;

- (id)initWithEventName:(NSString *)eventName data:(id)eventData;
{
  if (self = [super init]) {
    name = [eventName copy];
    data = [eventData copy];
  }
  return self;
}

- (void)dealloc;
{
  [name release];
  [data release];
  [super dealloc];
}

@end
