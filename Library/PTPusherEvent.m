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

@synthesize name = _name;
@synthesize data = _data;

- (id)initWithEventName:(NSString *)name data:(id)data
{
  if (self = [super init]) {
    _name = [name copy];
    
    if ([data respondsToSelector:@selector(JSONValue)]) {
      _data = [[data JSONValue] copy];
    }
    else {
      _data = [data copy];
    }
  }
  return self;
}

- (void)dealloc
{
  [_name release];
  [_data release];
  [super dealloc];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherEvent name:%@ data:%@>", self.name, self.data];
}

@end
