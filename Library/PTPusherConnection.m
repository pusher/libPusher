//
//  PTPusherConnection.m
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTPusherConnection.h"
#import "PTPusherEvent.h"
#import "JSON.h"

NSString *const PTPusherDataKey  = @"data";
NSString *const PTPusherEventKey = @"event";

@implementation PTPusherConnection

@synthesize delegate = _delegate;
@synthesize connected;
@synthesize socketID;

- (id)initWithURL:(NSURL *)aURL
{
  if ((self = [super init])) {
    socket = [[ZTWebSocket alloc] initWithURLString:[aURL absoluteString] delegate:self];
  }
  return self;
}

#pragma mark - Connection management

- (void)connect;
{
  [socket open];
}

- (void)disconnect;
{
  [socket close];
}

#pragma mark - ZTWebSocket delegate methods

- (void)webSocket:(ZTWebSocket*)webSocket didFailWithError:(NSError*)error;
{
  [self.delegate pusherConnection:self didFailWithError:error];
}

- (void)webSocketDidClose:(ZTWebSocket*)webSocket;
{
  connected = NO;
  [self.delegate pusherConnectionDidDisconnect:self];
}

- (void)webSocket:(ZTWebSocket*)webSocket didReceiveMessage:(NSString*)message;
{
  id messageDictionary = [message JSONValue];
  PTPusherEvent *event = [[PTPusherEvent alloc] initWithEventName:[messageDictionary valueForKey:PTPusherEventKey] data:[messageDictionary valueForKey:PTPusherDataKey]];
  
  if ([event.name isEqualToString:@"connection_established"]) {
    socketID = [[event.data objectForKey:@"socket_id"] integerValue];
    connected = YES;
    [self.delegate pusherConnectionDidConnect:self];
  }  
  [self.delegate pusherConnection:self didReceiveEvent:event];
  [event release];
}

@end
