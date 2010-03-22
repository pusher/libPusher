//
//  PTPusher.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusher.h"
#import "PTEventListener.h"
#import "SBJSON.h"

@implementation PTPusher

@synthesize APIKey;
@synthesize channel;

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
  id data = [message JSONValue];
  NSLog(@"Received %@", data);
}

- (void)webSocketDidSendMessage:(ZTWebSocket*)webSocket;
{

}

@end
