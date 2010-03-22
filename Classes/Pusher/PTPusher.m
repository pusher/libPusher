//
//  PTPusher.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusher.h"
#import "PTEventListener.h"
#import "NSString+SBJSON.h"

NSString *const PTPusherDataKey = @"data";
NSString *const PTPusherEventKey = @"event";

#pragma mark -

@implementation PTPusher

@synthesize APIKey;
@synthesize channel;
@synthesize socketID;

- (id)initWithKey:(NSString *)key channel:(NSString *)channelName;
{
  if (self = [super init]) {
    APIKey  = [key copy];
    channel = [channelName copy];
    eventListeners = [[NSMutableDictionary alloc] init];
    
    socket = [[ZTWebSocket alloc] initWithURLString:[NSString stringWithFormat:@"ws://ws.pusherapp.com:8080/app/%@?channel=%@", APIKey, channel] delegate:self];
    [socket open];
  }
  return self;
}

- (void)dealloc;
{
  [socket close];
  [socket release];
  [eventListeners release];
  [APIKey release];
  [channel release];
  [super dealloc];
}

#pragma mark -
#pragma mark Event listening

- (void)addEventListener:(NSString *)eventName target:(id)target selector:(SEL)selector;
{
  NSMutableArray *listeners = [eventListeners objectForKey:eventName];
  if (listeners == nil) {
    listeners = [[[NSMutableArray alloc] init] autorelease];
    [eventListeners setValue:listeners forKey:eventName];
  }
  PTEventListener *listener = [[PTEventListener alloc] initWithTarget:target selector:selector];
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

#pragma mark -
#pragma mark ZTWebSocketDelegate methods

- (void)webSocket:(ZTWebSocket*)webSocket didFailWithError:(NSError*)error;
{
  NSLog(@"WebSocket failed with error %@", error);
}

- (void)webSocketDidOpen:(ZTWebSocket*)webSocket;
{
  NSLog(@"WebSocket did open");
}

- (void)webSocketDidClose:(ZTWebSocket*)webSocket;
{
  NSLog(@"WebSocket did close");
}

- (void)webSocket:(ZTWebSocket*)webSocket didReceiveMessage:(NSString*)message;
{
  NSLog(@"Received %@", message);
  
  id messageDictionary = [message JSONValue];
  NSString *eventName = [messageDictionary valueForKey:PTPusherEventKey];
  id eventData = [messageDictionary valueForKey:PTPusherDataKey];
  
  if ([eventName isEqualToString:@"connection_established"]) {
    socketID = [[eventData valueForKey:@"socket_id"] intValue];
  }  
  [self handleEvent:eventName eventData:eventData];
}

@end
