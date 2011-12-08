//
//  PTPusherEvent.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusherEvent.h"
#import "JSONKit.h"

NSString *const PTPusherDataKey    = @"data";
NSString *const PTPusherEventKey   = @"event";
NSString *const PTPusherChannelKey = @"channel";

@implementation PTPusherEvent

@synthesize name = _name;
@synthesize data = _data;
@synthesize channel = _channel;

+ (id)eventFromMessageDictionary:(NSDictionary *)dictionary
{
  return [[[self alloc] initWithEventName:[dictionary objectForKey:PTPusherEventKey] channel:[dictionary objectForKey:PTPusherChannelKey] data:[dictionary objectForKey:PTPusherDataKey]] autorelease];
}

- (id)initWithEventName:(NSString *)name channel:(NSString *)channel data:(id)data
{
  if (self = [super init]) {
    _name = [name copy];
    _channel = [channel copy];
    
    // try and deserialize the data as JSON if possible
    if ([data respondsToSelector:@selector(dataUsingEncoding:)]) {
      NSError *error = nil;
      
      _data = [[data objectFromJSONString] copy];

      if (error) {
        _data = [data copy];
      }
    }
    else {
      _data = [data copy];
    }
  }
  return self;
}

- (void)dealloc
{
  [_channel release];
  [_name release];
  [_data release];
  [super dealloc];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherEvent channel:%@ name:%@ data:%@>", self.channel, self.name, self.data];
}

@end
