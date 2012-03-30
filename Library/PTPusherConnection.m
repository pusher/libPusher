//
//  PTPusherConnection.m
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTPusherConnection.h"
#import "PTPusherEvent.h"
#define SR_ENABLE_LOG
#import "SRWebSocket.h"
#import "PTJSON.h"

NSString *const PTPusherConnectionEstablishedEvent = @"pusher:connection_established";
NSString *const PTPusherConnectionPingEvent        = @"pusher:ping";

@interface PTPusherConnection ()
@property (nonatomic, copy) NSString *socketID;
@property (nonatomic, assign, readwrite) BOOL connected;

- (void)respondToPingEvent;
@end

@implementation PTPusherConnection {
  SRWebSocket *socket;
  NSURLRequest *request;
}

@synthesize delegate = _delegate;
@synthesize connected;
@synthesize socketID;


- (id)initWithURL:(NSURL *)aURL secure:(BOOL)secure
{
  return [self initWithURL:aURL secure:NO];
}

- (id)initWithURL:(NSURL *)aURL
{
  if ((self = [super init])) {
    request = [NSURLRequest requestWithURL:aURL];
  }
  return self;
}

- (void)dealloc 
{
  [socket close];
}

#pragma mark - Connection management

- (void)connect;
{
  if (self.isConnected)
    return;

  socket = [[SRWebSocket alloc] initWithURLRequest:request];
  socket.delegate = self;
  
  [socket open];
}

- (void)disconnect;
{
  if (!self.isConnected)
    return;
  
  [socket close];
}

#pragma mark - Sending data

- (void)send:(id)object
{
  NSData *JSONData = [[PTJSON JSONParser] JSONDataFromObject:object];
  NSString *message = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
  [socket send:message];
}

#pragma mark - ZTWebSocket delegate methods

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
  self.connected = YES;
  [self.delegate pusherConnectionDidConnect:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
  self.connected = NO;
  [self.delegate pusherConnection:self didFailWithError:error];
  self.socketID = nil;
  socket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
  self.connected = NO;
  [self.delegate pusherConnection:self didDisconnectWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean];
  self.socketID = nil;
  socket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
  NSDictionary *messageDictionary = [[PTJSON JSONParser] objectFromJSONString:message];
  PTPusherEvent *event = [PTPusherEvent eventFromMessageDictionary:messageDictionary];
  
  if ([event.name isEqualToString:PTPusherConnectionPingEvent]) {
    // don't forward on ping events, just handle them and return
    [self respondToPingEvent];
    return;
  }
  
  if ([event.name isEqualToString:PTPusherConnectionEstablishedEvent]) {
    self.socketID = [event.data objectForKey:@"socket_id"];
    
    [self.delegate pusherConnection:self didReceiveHandshakeEvent:event];
  }
  
  [self.delegate pusherConnection:self didReceiveEvent:event];
}

#pragma mark -

- (void)respondToPingEvent
{
#ifdef DEBUG
  NSLog(@"[pusher] Responding to ping (pong!)");
#endif
  
  [self send:[NSDictionary dictionaryWithObject:@"pusher:pong" forKey:@"event"]];
}

@end
