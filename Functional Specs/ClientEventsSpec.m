//
//  ClientEventsSpec.m
//  libPusher
//
//  Created by Luke Redpath on 07/06/2012.
//  Copyright 2012 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"

SPEC_BEGIN(ClientEventsSpec)

describe(@"Client events", ^{
  
  __block PTPusher *client = nil;
  __block PTPusherMockConnection *connection = nil;
  
  registerMatchers(@"PT");
  enableClientDebugging();
  
  beforeEach(^{
    client = newTestClientWithMockConnection();
    [client enableChannelAuthorizationBypassMode];
    connection = (PTPusherMockConnection *)client.connection;
  });
  
  it(@"can be sent to private channels", ^{
    onConnect(^{
      [client subscribeToPrivateChannelNamed:@"test-channel"];
    });
    
    onSubscribe(^(PTPusherChannel *channel) {
      [(PTPusherPrivateChannel *)channel triggerEventNamed:@"client-test-event" data:nil];
    });
    
    [client connect];
    
    [[expectFutureValue([connection.sentClientEvents lastObject]) shouldEventually] beEventNamed:@"client-test-event"];
    
    PTPusherEvent *lastEvent = [connection.sentClientEvents lastObject];
    [[lastEvent.name should] equal:@"client-test-event"];
    [[lastEvent.channel should] equal:@"private-test-channel"];
	});
  
  it(@"will have their name automatically prefixed with client-", ^{
    onConnect(^{
      [client subscribeToPrivateChannelNamed:@"test-channel"];
    });
    
    onSubscribe(^(PTPusherChannel *channel) {
      [(PTPusherPrivateChannel *)channel triggerEventNamed:@"test-event" data:nil];
    });
    
    [client connect];
    
    [[expectFutureValue([connection.sentClientEvents lastObject]) shouldEventually] beEventNamed:@"client-test-event"];
    
    PTPusherEvent *lastEvent = [connection.sentClientEvents lastObject];
    [[lastEvent.name should] equal:@"client-test-event"];
    [[lastEvent.channel should] equal:@"private-test-channel"];
	});
  
  it(@"can be sent prior to being subscribed", ^{
    onConnect(^{
      PTPusherPrivateChannel *channel = [client subscribeToPrivateChannelNamed:@"test-channel"];
      [channel triggerEventNamed:@"test-event" data:nil];
    });
    
    onSubscribe(^(PTPusherChannel *channel) {
      NSLog(@"here");
    });
    
    [client connect];
    
    [[expectFutureValue([connection.sentClientEvents lastObject]) shouldEventually] beEventNamed:@"client-test-event"];
    
    PTPusherEvent *lastEvent = [connection.sentClientEvents lastObject];
    [[lastEvent.name should] equal:@"client-test-event"];
    [[lastEvent.channel should] equal:@"private-test-channel"];
	});
});

SPEC_END
