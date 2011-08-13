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

NSURL *PTPusherConnectionURL(NSString *host, int port, NSString *key, NSString *clientID);

NSString *const PTPusherDataKey = @"data";
NSString *const PTPusherEventKey = @"event";
NSString *const PTPusherEventReceivedNotification = @"PTPusherEventReceivedNotification";

NSURL *PTPusherConnectionURL(NSString *host, int port, NSString *key, NSString *clientID)
{
  NSString *URLString = [NSString stringWithFormat:@"ws://%@:%d/app/%@?client=%@", host, port, key, clientID];
  return [NSURL URLWithString:URLString];
}

#define kPTPusherDefaultReconnectDelay 5.0

@interface PTPusher ()
@property (nonatomic, retain) PTPusherConnection *connection;
@end

#pragma mark -

@implementation PTPusher

@synthesize connection = _connection;
@synthesize delegate;
@synthesize reconnectAutomatically;
@synthesize reconnectDelay;

- (id)initWithConnection:(PTPusherConnection *)connection connectAutomatically:(BOOL)connectAutomatically
{
  if (self = [super init]) {
    eventListeners = [[NSMutableDictionary alloc] init];

    self.connection = connection;
    self.connection.delegate = self;
    
    self.reconnectAutomatically = NO;
    self.reconnectDelay = kPTPusherDefaultReconnectDelay;
    
    if (connectAutomatically) {
      [self.connection connect];
    }
  }
  return self;
}

+ (id)clientWithKey:(NSString *)key
{
  PTPusherConnection *connection = [[PTPusherConnection alloc] initWithURL:PTPusherConnectionURL(@"ws.pusherapp.com", 80, key, @"libpusher")];
  PTPusher *pusher = [[self alloc] initWithConnection:connection connectAutomatically:YES];
  [connection release];
  return [pusher autorelease];
}

- (void)dealloc;
{
  [_connection disconnect];
  [_connection release];
  [eventListeners release];
  [super dealloc];
}

- (BOOL)isConnected
{
  return [self.connection isConnected];
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
#pragma mark PTPusherConnection delegaet methods

- (void)pusherConnectionDidConnect:(PTPusherConnection *)connection
{
  
}

- (void)pusherConnectionDidDisconnect:(PTPusherConnection *)connection
{
  if (self.shouldReconnectAutomatically) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.reconnectDelay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      [connection connect];
    });
  }
}

- (void)pusherConnection:(PTPusherConnection *)connection didFailWithError:(NSError *)error
{
  
}

- (void)pusherConnection:(PTPusherConnection *)connection didReceiveEvent:(PTPusherEvent *)event
{
  NSArray *listenersForEvent = [eventListeners objectForKey:event.name];
  for (PTEventListener *listener in listenersForEvent) {
    [listener dispatch:event];
  }
  [[NSNotificationCenter defaultCenter] 
        postNotificationName:PTPusherEventReceivedNotification 
                      object:event];
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
