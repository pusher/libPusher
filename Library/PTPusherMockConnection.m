//
//  PTPusherMockConnection.m
//  libPusher
//
//  Created by Luke Redpath on 11/05/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "PTPusherMockConnection.h"
#import "PTJSON.h"
#import "PTPusherEvent.h"

@interface PTPusherMockConnection ()
@property (nonatomic, copy) NSString *socketID;
@property (nonatomic, assign) PTPusherConnectionState state;
@end

@implementation PTPusherMockConnection {
  NSMutableArray *sentClientEvents;
}

@synthesize sentClientEvents;
@synthesize socketID = _socketID;

- (id)init
{
  if ((self = [super initWithURL:nil])) {
    sentClientEvents = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)connect
{
  self.state = PTPusherConnectionConnecting;
  
  NSInteger socketID = (NSInteger)[NSDate timeIntervalSinceReferenceDate];

  [self simulateServerEventNamed:PTPusherConnectionEstablishedEvent 
                            data:@{@"socket_id": @(socketID)}];
}

- (void)disconnect
{
  self.state = PTPusherConnectionDisconnecting;
  self.socketID = nil;
}

- (void)send:(id)object
{
  [self handleClientEvent:object];
}

#pragma mark - Event simulation

- (void)simulateServerEventNamed:(NSString *)name data:(id)data
{
  [self simulateServerEventNamed:name data:data channel:nil];
}

- (void)simulateServerEventNamed:(NSString *)name data:(id)data channel:(NSString *)channelName
{
  NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
  
  eventDict[PTPusherEventKey] = name;
  
  if (data) {
    eventDict[PTPusherDataKey] = data;
  }
  
  if (channelName) {
    eventDict[PTPusherChannelKey] = channelName;
  }
  
  NSString *message = [[PTJSON JSONParser] JSONStringFromObject:eventDict];

  NSDictionary *messageDictionary = [[PTJSON JSONParser] objectFromJSONString:message];
  PTPusherEvent *event = [PTPusherEvent eventFromMessageDictionary:messageDictionary];

  if ([event.name isEqualToString:PTPusherConnectionEstablishedEvent]) {
    self.socketID = (event.data)[@"socket_id"];
    self.state = PTPusherConnectionConnected;

    [self.delegate pusherConnectionDidConnect:self];
  }

  [self.delegate pusherConnection:self didReceiveEvent:event];
}

- (void)simulateUnexpectedDisconnection
{
  self.state = PTPusherConnectionDisconnected;
  self.socketID = nil;
  // we always call this last, to prevent a race condition if the delegate calls 'connect'
  [self.delegate pusherConnection:self didDisconnectWithCode:kPTPusherSimulatedDisconnectionErrorCode reason:nil wasClean:NO];
}

#pragma mark - Client event handling

- (void)handleClientEvent:(NSDictionary *)eventData
{
  PTPusherEvent *event = [PTPusherEvent eventFromMessageDictionary:eventData];
  
  [sentClientEvents addObject:event];
  
  if ([event.name isEqualToString:@"pusher:subscribe"]) {
    [self handleSubscribeEvent:event];
  }
}

- (void)handleSubscribeEvent:(PTPusherEvent *)subscribeEvent
{
  [self simulateServerEventNamed:@"pusher_internal:subscription_succeeded" 
                            data:nil
                         channel:(subscribeEvent.data)[PTPusherChannelKey]];
}

@end
