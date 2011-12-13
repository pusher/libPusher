//
//  BasicEventHandling.m
//  libPusher
//
//  Created by Luke Redpath on 13/12/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"

#define kTEST_EVENT_NAME @"pusher-specs-test-event"
#define kTEST_CHANNEL    @"pusher-specs-test-channel"

SPEC_BEGIN(BasicEventHandling)

describe(@"Basic Event Handling", ^{
  
  __block PTPusher *client = nil;
  
  registerMatchers(@"PT");
  enableClientDebugging();
  
  beforeAll(^{
    client = newTestClient();
  });
  
  afterAll(^{
    [client disconnect];
  });
  
  it(@"will yield channel events bound to a block when published", ^{
    __block PTPusherEvent *theEvent = nil;
    
    PTPusherChannel *channel = [client subscribeToChannelNamed:kTEST_CHANNEL];
    
    [channel bindToEventNamed:kTEST_EVENT_NAME handleWithBlock:^(PTPusherEvent *event) {
      theEvent = [event retain];
    }];
    
    onConnect(^{
      sendTestEventOnChannel(kTEST_CHANNEL, kTEST_EVENT_NAME);
    });

    [[expectFutureValue(theEvent) shouldEventuallyBeforeTimingOutAfter(5)] beEventNamed:kTEST_EVENT_NAME];
	});
  
});

SPEC_END
