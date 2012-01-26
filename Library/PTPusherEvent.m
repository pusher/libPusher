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

@interface PTPusherErrorEvent ()
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end

@implementation PTPusherEvent

@synthesize name = _name;
@synthesize data = _data;
@synthesize channel = _channel;

+ (id)eventFromMessageDictionary:(NSDictionary *)dictionary
{
  if ([[dictionary objectForKey:PTPusherEventKey] isEqualToString:@"pusher:error"]) {
    return [[[PTPusherErrorEvent alloc] initWithDictionary:dictionary] autorelease];
  }
  return [[[self alloc] initWithEventName:[dictionary objectForKey:PTPusherEventKey] channel:[dictionary objectForKey:PTPusherChannelKey] data:[dictionary objectForKey:PTPusherDataKey]] autorelease];
}

- (id)initWithEventName:(NSString *)name channel:(NSString *)channel data:(id)data
{
  if (self = [super init]) {
    _name = [name copy];
    _channel = [channel copy];
    
    // try and deserialize the data as JSON if possible
    if ([data respondsToSelector:@selector(dataUsingEncoding:)]) {
      _data = [[data objectFromJSONString] copy];

      if (_data == nil) {
        NSLog(@"[pusher] Error parsing event data (not JSON?)");
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

#pragma mark -

@implementation PTPusherErrorEvent

@synthesize message = _message;
@synthesize code = _code;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
  if (self = [super init]) {
    _name = [dictionary objectForKey:@"event"];
    _message = [dictionary objectForKey:@"message"];
    _code = [[dictionary objectForKey:@"code"] integerValue];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherErrorEvent code:%d message:%@>", self.code, self.message];
}

@end
