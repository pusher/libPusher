//
//  PTMockConnectionSpec.m
//  libPusher
//
//  Created by Luke Redpath on 11/05/2012.
//  Copyright 2012 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"
#import "PTPusherMockConnection.h"
#import "PTPusher.h"
#import "PTPusher+Testing.h"
#import "PTPusherChannel.h"

SPEC_BEGIN(PTMockConnectionSpec)

describe(@"PTPusherMockConnectionSpec", ^{
  __block PTPusherMockConnection *connection = [[PTPusherMockConnection alloc] init];
  __block PTPusher *pusher = [[PTPusher alloc] initWithConnection:connection];
  
  it(@"handles connections and reports connected", ^{
    [[@(connection.isConnected) should] beFalse];
    [pusher connect];
    [[@(connection.isConnected) should] beTrue];
	});
  
  it(@"simulates a handshake event with a dummy socket ID after connecting", ^{
    [pusher connect];
    [[connection.socketID shouldNot] beNil];
	});
  
  it(@"handles disconnections and reports not connected", ^{
    [pusher connect];
    [pusher disconnect];
    [[@(connection.isConnected) should] beFalse];
	});
  
  it(@"simulates the correct response when subscribing to a public channel", ^{
    [pusher connect];
    PTPusherChannel *channel = [pusher subscribeToChannelNamed:@"test-channel"];
    [[expectFutureValue(@(channel.isSubscribed)) shouldEventually] beTrue];
	});
  
  it(@"simulates the correct response when subscribing to a private channel when auth bypass is enabled", ^{
    [pusher enableChannelAuthorizationBypassMode];
    [pusher connect];
    PTPusherChannel *channel = [pusher subscribeToPrivateChannelNamed:@"test-channel"];
    [[expectFutureValue(@(channel.isSubscribed)) shouldEventually] beTrue];
	});
  
  it(@"allows the direct simulation of server events", ^{
    [pusher connect];
    
    PTPusherChannel *channel = [pusher subscribeToChannelNamed:@"test-channel"];
    
    __block PTPusherEvent *receivedEvent = nil;
    
    [channel bindToEventNamed:@"test-event" handleWithBlock:^(PTPusherEvent *event) {
      receivedEvent = event;
    }];
    
    [connection simulateServerEventNamed:@"test-event" data:nil channel:@"test-channel"];
    
    [[expectFutureValue(receivedEvent) shouldEventually] beNonNil];
	});
});

SPEC_END
