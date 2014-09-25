//
//  BasicEventHandling.m
//  libPusher
//
//  Created by Luke Redpath on 13/12/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"

#define kTEST_EVENT_NAME @"libpusher-specs-test-event"
#define kTEST_CHANNEL    @"libpusher-specs-test-channel"

SPEC_BEGIN(BasicEventHandling)

describe(@"A pusher channel", ^{
  
  __block PTPusher *client = nil;
  
  registerMatchers(@"PT");
  enableClientDebugging();
  
  beforeAll(^{
    client = newTestClient();
  });
  
  afterAll(^{
    [client disconnect];
    waitForClientToDisconnect(client);
  });
  
  context(@"when publishing events", ^{
    it(@"will yield events to block handlers bound to the channel", ^{
      __block PTPusherEvent *theEvent = nil;
      
      PTPusherChannel *channel = [client subscribeToChannelNamed:kTEST_CHANNEL];
      
      [channel bindToEventNamed:kTEST_EVENT_NAME handleWithBlock:^(PTPusherEvent *event) {
        theEvent = event;
      }];
      
      onConnect(^{
        sendTestEventOnChannel(kTEST_CHANNEL, kTEST_EVENT_NAME);
      });
      
      [[expectFutureValue(theEvent) shouldEventuallyBeforeTimingOutAfter(5)] beEventNamed:kTEST_EVENT_NAME];
    });
    
    it(@"will yield events to block handlers bound to the client", ^{
      __block PTPusherEvent *theEvent = nil;
      
      [client subscribeToChannelNamed:kTEST_CHANNEL];
      
      [client bindToEventNamed:kTEST_EVENT_NAME handleWithBlock:^(PTPusherEvent *event) {
        theEvent = event;
      }];
      
      onConnect(^{
        sendTestEventOnChannel(kTEST_CHANNEL, kTEST_EVENT_NAME);
      });
      
      [[expectFutureValue(theEvent) shouldEventuallyBeforeTimingOutAfter(5)] beEventNamed:kTEST_EVENT_NAME];
    });
    
    it(@"will not yield events to handlers who have had their bindings removed", ^{
	    __block PTPusherEvent *theEvent = nil;
      __block PTPusherEvent *theEventFromUnboundBlock = nil;
      
      [client subscribeToChannelNamed:kTEST_CHANNEL];
      
      PTPusherEventBinding *binding = [client bindToEventNamed:kTEST_EVENT_NAME handleWithBlock:^(PTPusherEvent *event) {
        theEventFromUnboundBlock = event;
      }];
      
      // we'll use this one to confirm the event has been dispatched
      [client bindToEventNamed:kTEST_EVENT_NAME handleWithBlock:^(PTPusherEvent *event) {
        theEvent = event;
      }];
      
      [client removeBinding:binding];
      
      onConnect(^{
        sendTestEventOnChannel(kTEST_CHANNEL, kTEST_EVENT_NAME);
      });
      
      [[expectFutureValue(theEvent) shouldEventuallyBeforeTimingOutAfter(5)] beEventNamed:kTEST_EVENT_NAME];
      [[expectFutureValue(theEventFromUnboundBlock) should] beNil];
    });
    
    it(@"will not yield events to handlers after all bindings have been removed", ^{
	    __block PTPusherEvent *theEvent = nil;
      __block PTPusherEvent *theEventFromUnboundBlock = nil;
      
      [client subscribeToChannelNamed:kTEST_CHANNEL];
      
      [client bindToEventNamed:kTEST_EVENT_NAME handleWithBlock:^(PTPusherEvent *event) {
        theEventFromUnboundBlock = event;
      }];
      
      [client removeAllBindings];
      
      // we'll use this one to confirm the event has been dispatched
      [client bindToEventNamed:kTEST_EVENT_NAME handleWithBlock:^(PTPusherEvent *event) {
        theEvent = event;
      }];
      
      onConnect(^{
        sendTestEventOnChannel(kTEST_CHANNEL, kTEST_EVENT_NAME);
      });
      
      [[expectFutureValue(theEvent) shouldEventuallyBeforeTimingOutAfter(5)] beEventNamed:kTEST_EVENT_NAME];
      [[expectFutureValue(theEventFromUnboundBlock) should] beNil];
    });
    
    it(@"will notify observers of channel events using NSNotification", ^{
      __block PTPusherEvent *theEvent = nil;
      
      PTPusherChannel *channel = [client subscribeToChannelNamed:kTEST_CHANNEL];
      
      [[NSNotificationCenter defaultCenter] addObserver:PTPusherEventReceivedNotification object:channel usingBlock:^(NSNotification *note) {
        theEvent = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
      }];
      
      onConnect(^{
        sendTestEventOnChannel(kTEST_CHANNEL, kTEST_EVENT_NAME);
      });
      
      [[expectFutureValue(theEvent) shouldEventuallyBeforeTimingOutAfter(5)] beEventNamed:kTEST_EVENT_NAME];
    });
    
    it(@"will notify observers of all client events using NSNotification", ^{
      __block PTPusherEvent *theEvent = nil;
      
      [client subscribeToChannelNamed:kTEST_CHANNEL];
      
      [[NSNotificationCenter defaultCenter] addObserver:PTPusherEventReceivedNotification object:client usingBlock:^(NSNotification *note) {
        theEvent = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
      }];
      
      onConnect(^{
        sendTestEventOnChannel(kTEST_CHANNEL, kTEST_EVENT_NAME);
      });
      
      [[expectFutureValue(theEvent) shouldEventuallyBeforeTimingOutAfter(5)] beEventNamed:kTEST_EVENT_NAME];
    });
  });
});

SPEC_END
