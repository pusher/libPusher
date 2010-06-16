//
//  PTPusher.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusher.h"
#import "PTEventListener.h"
#import "JSON.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"

NSString *const PTPusherDataKey = @"data";
NSString *const PTPusherEventKey = @"event";
NSString *const PTPusherEventReceivedNotification = @"PTPusherEventReceivedNotification";

#define kPTPusherReconnectDelay 5.0

@interface PTPusher ()
- (NSString *)URLString;
- (void)handleEvent:(PTPusherEvent *)event;
- (void)connect;
@property (nonatomic, readonly) NSString *URLString;
@end

#pragma mark -

@implementation PTPusher

@synthesize APIKey;
@synthesize channel;
@synthesize socketID;
@synthesize host;
@synthesize port;
@synthesize delegate;
@synthesize reconnect;
@dynamic URLString;

- (id)initWithKey:(NSString *)key channel:(NSString *)channelName;
{
  if (self = [super init]) {
    APIKey  = [key copy];
    channel = [channelName copy];
    eventListeners = [[NSMutableDictionary alloc] init];
    host = @"ws.pusherapp.com";
    port = 80;
    delegate = nil;
    reconnect = NO;
    
    socket = [[ZTWebSocket alloc] initWithURLString:self.URLString delegate:self];
    [self connect];
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

- (NSString *)description;
{
  return [NSString stringWithFormat:@"<PTPusher channel:%@>", channel];
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

- (void)handleEvent:(PTPusherEvent *)event;
{
  NSArray *listenersForEvent = [eventListeners objectForKey:event.name];
  for (PTEventListener *listener in listenersForEvent) {
    [listener dispatch:event];
  }
  [[NSNotificationCenter defaultCenter] 
    postNotificationName:PTPusherEventReceivedNotification object:event];
}

#pragma mark -
#pragma mark ZTWebSocketDelegate methods

- (void)webSocket:(ZTWebSocket*)webSocket didFailWithError:(NSError*)error;
{
  if ([delegate respondsToSelector:@selector(pusherDidFailToConnect:withError:)]) {
    [delegate pusherDidFailToConnect:self withError:error];
  }
}

- (void)webSocketDidOpen:(ZTWebSocket*)webSocket;
{
  if ([delegate respondsToSelector:@selector(pusherDidConnect:)]) {
    [delegate pusherDidConnect:self];
  }
}

- (void)webSocketDidClose:(ZTWebSocket*)webSocket;
{
  if ([delegate respondsToSelector:@selector(pusherDidDisconnect:)]) {
    [delegate pusherDidDisconnect:self];
  }
  
  if (self.reconnect) {
    if ([delegate respondsToSelector:@selector(pusherWillReconnect:afterDelay:)]) {
      [delegate pusherWillReconnect:self afterDelay:kPTPusherReconnectDelay];
    }
    [self performSelector:@selector(connect) withObject:nil afterDelay:kPTPusherReconnectDelay];
  }
}

- (void)webSocket:(ZTWebSocket*)webSocket didReceiveMessage:(NSString*)message;
{
  id messageDictionary = [message JSONValue];
  PTPusherEvent *event = [[PTPusherEvent alloc] initWithEventName:[messageDictionary valueForKey:PTPusherEventKey] data:[messageDictionary valueForKey:PTPusherDataKey] channel:self.channel];
  
  if ([event.name isEqualToString:@"connection_established"]) {
    socketID = [[event.data valueForKey:@"socket_id"] intValue];
  }  
  [self handleEvent:event];
  [event release];
}

#pragma mark -
#pragma mark Private methods

- (NSString *)URLString;
{
  return [NSString stringWithFormat:@"ws://%@:%d/app/%@?channel=%@",
          self.host, self.port, self.APIKey, self.channel];
}

- (void)connect;
{
  if ([delegate respondsToSelector:@selector(pusherWillConnect:)]) {
    [delegate pusherWillConnect:self];
  }
  [socket open];
}

@end

#pragma mark -

@implementation PTPusher (SharedFactory)

static NSString *sharedKey = nil;
static NSString *sharedSecret = nil;
static NSString *sharedAppID = nil;

+ (void)setKey:(NSString *)apiKey;
{
  [sharedKey autorelease]; sharedKey = [apiKey copy];
}

+ (void)setSecret:(NSString *)secret;
{
  [sharedSecret autorelease]; sharedSecret = [secret copy];
}

+ (void)setAppID:(NSString *)appId;
{
  [sharedAppID autorelease]; sharedAppID = [appId copy];
}

+ (PTPusherChannel *)channel:(NSString *)name;
{
  return [[self newChannel:name] autorelease];
}

+ (PTPusherChannel *)newChannel:(NSString *)name;
{
  return [[PTPusherChannel alloc] initWithName:name appID:sharedAppID key:sharedKey secret:sharedSecret];
}

@end
