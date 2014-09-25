//
//  PrivateChannelsSpec.m
//  libPusher
//
//  Created by Luke Redpath on 29/02/2012.
//  Copyright 2012 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"
#import "NSMutableURLRequest+BasicAuth.h"
#import "PTPusherChannel.h"

SPEC_BEGIN(PrivateChannelsSpec)

describe(@"Subscribing to a private channel", ^{
  
  __block PTPusher *client = nil;
  
  registerMatchers(@"PT");
  enableClientDebugging();
  
  beforeAll(^{
    client = newTestClient();
    
    // this requires the auth server to be running (rake authserver:start)
    client.authorizationURL = [NSURL URLWithString:@"http://localhost:9292/private/auth"];
  });
  
  afterAll(^{
    [client disconnect];
    waitForClientToDisconnect(client);
  });
  
  it(@"succeeds when authorization is successful", ^{
    onAuthorizationRequired(^(NSMutableURLRequest *authRequest) {
      [authRequest setHTTPBasicAuthUsername:@"admin" password:@"letmein"];
    });
    
    __block PTPusherPrivateChannel *channel = nil;
    
    onConnect(^{
      channel = [client subscribeToPrivateChannelNamed:@"secret-channel"];
    });
    
    __block BOOL subscribed = NO;
    
    onSubscribe(^(PTPusherChannel *subscribedChannel) {
      if (subscribedChannel == (PTPusherChannel *)channel) {
        subscribed = YES;
      }
    });
    
    [[expectFutureValue(@(subscribed)) shouldEventuallyBeforeTimingOutAfter(3)] beYes];
	});
  
  it(@"fails when authorization fails", ^{
    onAuthorizationRequired(^(NSMutableURLRequest *authRequest) {
      [authRequest setHTTPBasicAuthUsername:@"admin" password:@"wrongpassword"];
    });
    
    __block PTPusherPrivateChannel *channel = nil;
    
    onConnect(^{
      channel = [client subscribeToPrivateChannelNamed:@"secret-channel"];
    });
    
    __block BOOL failedToSubscribe = NO;
    
    onFailedToSubscribe(^(PTPusherChannel *failedChannel) {
      if (failedChannel == (PTPusherChannel *)channel) {
        failedToSubscribe = YES;
      }
    });
    
    [[expectFutureValue(@(failedToSubscribe)) shouldEventuallyBeforeTimingOutAfter(3)] beYes];
	});
});

describe(@"Subscribing to multiple private channels with delays (see issue #26)", ^{
  
  __block PTPusher *client = nil;
  
  registerMatchers(@"PT");
  enableClientDebugging();
  
  beforeAll(^{
    client = newTestClient();
    
    // this requires the auth server to be running (rake authserver:start)
    client.authorizationURL = [NSURL URLWithString:@"http://localhost:9292/private/slowauth"];
  });
  
  afterAll(^{
    [client disconnect];
    waitForClientToDisconnect(client);
  });
  
  it(@"should be successful", ^{
    onAuthorizationRequired(^(NSMutableURLRequest *authRequest) {
      [authRequest setHTTPBasicAuthUsername:@"admin" password:@"letmein"];
    });
    
    NSInteger numberToConnect = 5;
    
    onConnect(^{
      for (int i = 0; i < numberToConnect; i++) {
        [client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"secret-channel-%d", i]]; 
      }
    });
    
    __block NSInteger numberOfSubscribedChannels = 0;
    __block BOOL allSubscribed = NO;
    
    onSubscribe(^(PTPusherChannel *subscribedChannel) {
      numberOfSubscribedChannels++;
      
      if (numberOfSubscribedChannels == numberToConnect) {
        allSubscribed = YES;
      }
    });

    [[expectFutureValue(@(allSubscribed)) shouldEventuallyBeforeTimingOutAfter(10)] beYes];
	});
});

SPEC_END
