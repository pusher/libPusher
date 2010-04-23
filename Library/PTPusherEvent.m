//
//  PTPusherEvent.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusherEvent.h"
#import "JSON.h"

@implementation PTPusherEvent

@synthesize name, channel;
@dynamic data;

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

- (id)data;
{
  id parsedData = nil;
  if ([data respondsToSelector:@selector(JSONValue)]) {
    parsedData = [data JSONValue];
  }
  if (parsedData == nil) {
    parsedData = data;
  }
  return parsedData;
}

@end
