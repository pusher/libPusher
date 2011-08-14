//
//  PTPusherConnection.m
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTPusherConnection.h"
#import "PTPusherEvent.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

NSString *const PTPusherConnectionEstablishedEvent = @"connection_established";

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

- (void)dealloc 
{
  [socket close];
  [socket release];
  [socketID release];
  [super dealloc];
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

#pragma mark - Sending data

- (void)send:(id)object
{
  NSData *JSONData = [[CJSONSerializer serializer] serializeObject:object error:nil];
  NSString *message = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
  [socket send:message];
  [message release];
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
  NSDictionary *messageDictionary = [[CJSONDeserializer deserializer] deserialize:[message dataUsingEncoding:NSUTF8StringEncoding] error:nil];
  PTPusherEvent *event = [PTPusherEvent eventFromMessageDictionary:messageDictionary];
  
  if ([event.name isEqualToString:PTPusherConnectionEstablishedEvent]) {
    socketID = [[event.data objectForKey:@"socket_id"] copy];
    connected = YES;
    [self.delegate pusherConnectionDidConnect:self];
  }  
  [self.delegate pusherConnection:self didReceiveEvent:event];
}

@end
