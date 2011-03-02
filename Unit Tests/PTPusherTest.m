//
//  PTPusherTest.m
//  libPusher
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusher.h"
#import "PTPusherEvent.h"

SPEC_BEGIN(PTPusherSpec)

describe(@"PTPusher", ^{
  
  __block PTPusher *pusher = nil;
  
  beforeEach(^{
    pusher = [[PTPusher alloc] initWithKey:@"api_key" delegate:nil];
    [pusher subscribeToChannel:@"test_channel" withAuthPoint:nil delegate:nil];
  });
             
  it(@"should dispatch event to target/action listener when event is received", ^{
    id mockListener = [KWMock mockForClass:[NSObject class]];
    
    SEL callback = @selector(handleEvent:);
    [pusher addEventListener:@"test-event" target:mockListener selector:callback];
    
    [[mockListener should] receive:callback];
    
    NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
    [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
  });
  
  it(@"should dispatch to multiple target/action listeners when an event is received", ^{
    
  });
  
  it(@"should pass an event to an event listener when an event is received", ^{
    
  });
  
  pending(@"it should post a notification when an event is received", ^{
  });
  
  pending(@"it should post event as the notification object when an event is received", ^{
  });
  
  it(@"should parse encoded JSON received in the data key", ^{
    
  });
         
             //
             //- (void)testShouldDispatchToMultipleListenersWhenAnEventIsReceived;
             //{
             //  SEL callback = @selector(handleEvent:);
             //  
             //  id mockListenerOne = [OCMockObject mockForClass:[NSObject class]];
             //  [[mockListenerOne expect] performSelectorOnMainThread:callback withObject:[OCMArg any] waitUntilDone:NO];
             //  
             //  id mockListenerTwo = [OCMockObject mockForClass:[NSObject class]];
             //  [[mockListenerTwo expect] performSelectorOnMainThread:callback withObject:[OCMArg any] waitUntilDone:NO];
             //  
             //  [pusher addEventListener:@"test-event" target:mockListenerOne selector:callback];
             //  [pusher addEventListener:@"test-event" target:mockListenerTwo selector:callback];
             //  
             //  NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
             //  [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
             //  [mockListenerOne verify];
             //  [mockListenerTwo verify];
             //}
             //
             //- (void)testShouldPassAnEventToAnEventListenerWhenAnEventIsReceived;
             //{
             //  id mockListener = [OCMockObject mockForClass:[NSObject class]];
             //  SEL callback = @selector(handleEvent:);
             //  [[mockListener expect] performSelectorOnMainThread:callback withObject:[OCMArg checkWithSelector:@selector(verifyBasicEvent:) onObject:self] waitUntilDone:NO];
             //  
             //  [pusher addEventListener:@"test-event" target:mockListener selector:@selector(handleEvent:)];
             //  
             //  NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
             //  [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
             //}
             //- (BOOL)verifyBasicEvent:(PTPusherEvent *)event;
             //{
             //  if (event == nil) return NO;
             //  assertThat(event.name, equalTo(@"test-event"));
             //  assertThat(event.data, equalTo(@"some data"));
             //  return YES;
             //}
             //
             //- (void)testShouldPostNotificationWhenEventIsReceived;
             //{
             //  [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:PTPusherEventReceivedNotification object:nil];
             //  
             //  [[observerMock expect] notificationWithName:PTPusherEventReceivedNotification object:[OCMArg any]];
             //  
             //  NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
             //  [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
             //  [observerMock verify];
             //}
             //
             //- (void)testShouldPassEventAsNotificationObjectWhenEventIsReceived;
             //{
             //  [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:PTPusherEventReceivedNotification object:nil];
             //  
             //  [[observerMock expect] notificationWithName:PTPusherEventReceivedNotification object:[OCMArg checkWithSelector:@selector(verifyNotificationEvent:) onObject:self]];
             //  
             //  NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
             //  [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
             //  [observerMock verify];
             //}
             //- (BOOL)verifyNotificationEvent:(PTPusherEvent *)event;
             //{
             //  if (event == nil) return NO;
             //  assertThat(event.name, equalTo(@"test-event"));
             //  assertThat(event.data, equalTo(@"some data"));
             //  return YES;
             //}
             //
             //- (void)testShouldParseEncodedJsonDataReceivedInDataKey;
             //{
             //  id mockListener = [OCMockObject mockForClass:[NSObject class]];
             //  SEL callback = @selector(handleEvent:);
             //  [[mockListener expect] performSelectorOnMainThread:callback withObject:[OCMArg checkWithSelector:@selector(verifyEventEncodedJSON:) onObject:self] waitUntilDone:NO];
             //  
             //  [pusher addEventListener:@"test-event" target:mockListener selector:@selector(handleEvent:)];
             //  
             //  NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":{\\\"foo\\\":\\\"bar\\\"}}";
             //  [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
             //}
             //- (BOOL)verifyEventEncodedJSON:(PTPusherEvent *)event;
             //{
             //  if (event == nil) return NO;
             //  assertThat([event.data valueForKey:@"foo"], equalTo(@"bar"));
             //  return YES;
             //}
             //
             //- (void)testShouldParseUnencodedJsonDataReceivedInDataKey;
             //{
             //  id mockListener = [OCMockObject mockForClass:[NSObject class]];
             //  SEL callback = @selector(handleEvent:);
             //  [[mockListener expect] performSelectorOnMainThread:callback withObject:[OCMArg checkWithSelector:@selector(verifyEventUnencodedJSON:) onObject:self] waitUntilDone:NO];
             //  
             //  [pusher addEventListener:@"test-event" target:mockListener selector:@selector(handleEvent:)];
             //  
             //  NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":{\"foo\":\"bar\"}}";
             //  [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
             //}
             //- (BOOL)verifyEventUnencodedJSON:(PTPusherEvent *)event;
             //{
             //  if (event == nil) return NO;
             //  assertThat([event.data valueForKey:@"foo"], equalTo(@"bar"));
             //  return YES;
             //}
             
});

SPEC_END
