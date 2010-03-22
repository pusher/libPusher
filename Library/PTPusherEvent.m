//
//  PTPusherEvent.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusherEvent.h"


@implementation PTPusherEvent

@synthesize name, data, channel;

- (id)initWithEventName:(NSString *)eventName data:(id)eventData channel:(NSString *)eventChannel;
{
  if (self = [super init]) {
    name = [eventName copy];
    data = [eventData copy];
    channel = [eventChannel copy];
  }
  return self;
}

- (void)dealloc;
{
  [channel release];
  [name release];
  [data release];
  [super dealloc];
}

- (NSString *)description;
{
  return [NSString stringWithFormat:@"<PTPusherEvent channel:%@ name:%@ data:%@>", channel, name, data];
}

@end
