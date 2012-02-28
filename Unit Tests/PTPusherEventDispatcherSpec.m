//
//  PTPusherEventDispatcherSpec.m
//  libPusher
//
//  Created by Luke Redpath on 28/02/2012.
//  Copyright 2012 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"
#import "PTPusherEventDispatcher.h"

SPEC_BEGIN(PTPusherEventDispatcherSpec)

describe(@"PTPusherEventDispatcher", ^{
  
  __block PTPusherEventDispatcher *dispatcher = nil;
  
  beforeEach(^{
    dispatcher = [[PTPusherEventDispatcher alloc] init];
  });
  
  it(@"dispatches events to registered listeners for events with a matching name", ^{
    id mockListener = [KWMock mockForProtocol:@protocol(PTEventListener)];
    [dispatcher addEventListener:mockListener forEventNamed:@"test-event"];
    PTPusherEvent *event = anEventNamed(@"test-event");
    [[[mockListener should] receive] dispatchEvent:event];
    [dispatcher dispatchEvent:event];
  });

  it(@"doesn't dispatch events to registered listeners for events with a different name", ^{
    id mockListener = [KWMock mockForProtocol:@protocol(PTEventListener)];
    [dispatcher addEventListener:mockListener forEventNamed:@"test-event"];
    PTPusherEvent *event = anEventNamed(@"another-event");
    [[[mockListener shouldNot] receive] dispatchEvent:event];
    [dispatcher dispatchEvent:event];
  });

  it(@"allows listeners to unregister for any event", ^{
    id mockListener = [KWMock mockForProtocol:@protocol(PTEventListener)];
    [dispatcher addEventListener:mockListener forEventNamed:@"test-event"];
    [dispatcher removeEventListener:mockListener];
    PTPusherEvent *event = anEventNamed(@"test-event");
    [[[mockListener shouldNot] receive] dispatchEvent:event];
    [dispatcher dispatchEvent:event];
  });

  it(@"allows listeners to unregister for a specific event", ^{
    id mockListener = [KWMock mockForProtocol:@protocol(PTEventListener)];
    [dispatcher addEventListener:mockListener forEventNamed:@"test-event"];
    [dispatcher addEventListener:mockListener forEventNamed:@"another-event"];
    [dispatcher removeEventListener:mockListener forEventNamed:@"test-event"];
    PTPusherEvent *eventOne = anEventNamed(@"test-event");
    [[[mockListener shouldNot] receive] dispatchEvent:eventOne];
    PTPusherEvent *eventTwo = anEventNamed(@"another-event");
    [[[mockListener should] receive] dispatchEvent:eventTwo];
    [dispatcher dispatchEvent:eventOne];
    [dispatcher dispatchEvent:eventTwo];
  });
  
});

SPEC_END
