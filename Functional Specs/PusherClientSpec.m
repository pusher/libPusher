//
//  ConnectionManagementSpec.m
//  libPusher
//
//  Created by Luke Redpath on 17/05/2012.
//  Copyright 2012 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"
#import "PTPusherChannel.h"

SPEC_BEGIN(PusherClientSpec)

describe(@"Pusher client", ^{
  
  __block PTPusher *client = nil;
  
  registerMatchers(@"PT");
  enableClientDebugging();
  
  beforeEach(^{
    client = newTestClientDisconnected();
  });
  
  afterEach(^{
    [client disconnect];
    waitForClientToDisconnect(client);
  });
  
  it(@"allows you to subscribe to channels before connecting", ^{
    PTPusherChannel *channel = [client subscribeToChannelNamed:@"test-channel"];
    
    __block PTPusherChannel *subscribedChannel = nil;
    
    onSubscribe(^(PTPusherChannel *channel) {
      subscribedChannel = channel;
      [channel unsubscribe]; // clean-up
    });
    
    [client connect];
    
    [[expectFutureValue(subscribedChannel) shouldEventuallyBeforeTimingOutAfter(3)] equal:channel];
	});
  
  it(@"allows you to call unsubscribe without an exception if disconnected", ^{  
    __block PTPusherChannel *channel = nil;

    onSubscribe(^(PTPusherChannel *subscribedChannel) {
      channel = subscribedChannel;
      [client disconnect];
    });
    
    onDisconnect(^{
      [channel unsubscribe];
    });
    
    onConnect(^{
      [client subscribeToChannelNamed:@"test-channel"];
    });
    
    [client connect];
    
    // we need to wait for the channel so we know we are subscribed
    [[expectFutureValue(channel) shouldEventuallyBeforeTimingOutAfter(3)] beNonNil];
    
    // without the above expectation, this will pass immediately, before the channel has subscribed
    [[expectFutureValue([NSNumber numberWithBool:channel.isSubscribed]) shouldEventually] equal:[NSNumber numberWithBool:NO]];
	});
});

SPEC_END
