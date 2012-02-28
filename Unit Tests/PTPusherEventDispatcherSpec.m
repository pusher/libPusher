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

  it(@"allows listeners to unregister for an event by removing it's binding", ^{
    id mockListener = [KWMock mockForProtocol:@protocol(PTEventListener)];
    PTPusherEventBinding *binding = [dispatcher addEventListener:mockListener forEventNamed:@"test-event"];
    [dispatcher removeBinding:binding];
    PTPusherEvent *eventOne = anEventNamed(@"test-event");
    [[[mockListener shouldNot] receive] dispatchEvent:eventOne];
    [dispatcher dispatchEvent:eventOne];
  });
  
});

SPEC_END
