//
//  PTPusher.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusher.h"
#import "PTEventListener.h"

@implementation PTPusher

@synthesize APIKey;
@synthesize channel;

- (id)initWithKey:(NSString *)key channel:(NSString *)channelName;
{
  if (self = [super init]) {
    APIKey  = [key copy];
    channel = [channelName copy];
    eventListeners = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc;
{
  [eventListeners release];
  [APIKey release];
  [channel release];
  [super dealloc];
}

#pragma mark -
#pragma mark Event listening

- (void)addEventListener:(NSString *)eventName target:(id)target selector:(SEL)selector;
{
  PTEventListener *listener = [[PTEventListener alloc] initWithTarget:target selector:selector];
  
  NSMutableArray *listeners = [eventListeners objectForKey:eventName];
  if (listeners == nil) {
    listeners = [[[NSMutableArray alloc] init] autorelease];
  }
  [listeners addObject:listener];
  [listener release];
}

#pragma mark -
#pragma mark Event handling

- (void)handleEvent:(NSString *)eventName eventData:(id)data;
{
  NSArray *listenersForEvent = [eventListeners objectForKey:eventName];
  for (PTEventListener *listener in listenersForEvent) {
    [listener dispatch:data];
  }
}

@end
