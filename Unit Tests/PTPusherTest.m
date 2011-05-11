//
//  PTPusherTest.m
//  libPusher
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "Kiwi.h"

@protocol MockListener <NSObject>
- (void)handleEvent:(PTPusherEvent *)event;
@end

@interface PTEventMatcher : HCBaseMatcher
{
  NSString *eventName;
  NSString *eventData;
}
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *eventData;
@end

@implementation PTEventMatcher

@synthesize eventName, eventData;

- (BOOL)matches:(PTPusherEvent *)event
{
  BOOL matches = YES;
  
  if (self.eventName) {
    matches = [self.eventName isEqualToString:event.name];
  }
  if (self.eventData) {
    matches = [self.eventData isEqualToString:event.data];
  }
  return matches;
}

@end

id anEventWithName(NSString *name)
{
  PTEventMatcher *matcher = [[PTEventMatcher alloc] init];
  matcher.eventName = name;
  return [matcher autorelease];
}

id anEventWithNameAndData(NSString *name, NSString *data)
{
  PTEventMatcher *matcher = [[PTEventMatcher alloc] init];
  matcher.eventName = name;
  matcher.eventData = data;
  return [matcher autorelease];
}

SPEC_BEGIN(PTPusherSpec)

describe(@"PTPusher", ^{
  
  __block PTPusher *pusher = nil;
  
  beforeEach(^{
    pusher = [[PTPusher alloc] initWithKey:@"api_key" delegate:nil];
    [pusher subscribeToChannel:@"test_channel" withAuthPoint:nil delegate:nil];
  });
             
  it(@"should dispatch event to target/action listener when event is received", ^{
    id mockListener = [KWMock mockForProtocol:@protocol(MockListener)];
    
    SEL callback = @selector(handleEvent:);
    [pusher addEventListener:@"test-event" target:mockListener selector:callback];
    
    [[[mockListener should] receive] handleEvent:anything()];
    
    NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
    [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
  });
  
  it(@"should dispatch to multiple target/action listeners when an event is received", ^{
    id mockListenerOne = [KWMock mockForProtocol:@protocol(MockListener)];
    id mockListenerTwo = [KWMock mockForProtocol:@protocol(MockListener)];
    
    SEL callback = @selector(handleEvent:);
    [pusher addEventListener:@"test-event" target:mockListenerOne selector:callback];
    [pusher addEventListener:@"test-event" target:mockListenerTwo selector:callback];
    
    [[[mockListenerOne should] receive] handleEvent:instanceOf([PTPusherEvent class])];
    [[[mockListenerTwo should] receive] handleEvent:instanceOf([PTPusherEvent class])];
    
    NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
    [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
  });
  
  it(@"should pass the event to an event listener when an event is received", ^{
    id mockListener = [KWMock mockForProtocol:@protocol(MockListener)];
    
    SEL callback = @selector(handleEvent:);
    [pusher addEventListener:@"test-event" target:mockListener selector:callback];
    
    [[[mockListener should] receive] handleEvent:anEventWithNameAndData(@"test-event", @"some data")];
    
    NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
    [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
  });
  
  it(@"it should post a notification when an event is received", ^{
    __block NSNotification *theNote = nil;
    
    [[NSNotificationCenter defaultCenter] 
        addObserverForName:PTPusherEventReceivedNotification 
                    object:nil queue:nil usingBlock:^(NSNotification *note) {                        
       
        theNote = [note retain];
    }];
    
    [[theObject(&theNote) shouldEventually] beNonNil];
    
    NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
    [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
  });
  
  it(@"it should post event as the notification object when an event is received", ^{
    __block PTPusherEvent *event = nil;
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:PTPusherEventReceivedNotification 
     object:nil queue:nil usingBlock:^(NSNotification *note) {                        
       
       event = note.object;
     }];
    
    [[theObject(&event) shouldEventually] match:instanceOf([PTPusherEvent class])];
    
    NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"some data\"}";
    [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
  });
  
  it(@"should support block-based event handlers", ^{
    __block PTPusherEvent *event = nil;
    
    [pusher addEventListener:@"test-event" block:^(PTPusherEvent *theEvent) {
      event = [theEvent retain];
    }];
    
    NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"{\\\"foo\\\":\\\"bar\\\"}\"}";
    [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
    
    [[theObject(&event) shouldEventually] match:instanceOf([PTPusherEvent class])];
  });
  
  it(@"should parse encoded JSON received in the data key", ^{
    __block PTPusherEvent *event = nil;
    
    [pusher addEventListener:@"test-event" block:^(PTPusherEvent *theEvent) {
      event = [theEvent retain];
    }];
    
    NSString *rawJSON = @"{\"event\":\"test-event\",\"data\":\"{\\\"foo\\\":\\\"bar\\\"}\"}";
    [pusher performSelector:@selector(webSocket:didReceiveMessage:) withObject:nil withObject:rawJSON];
    
    [[theObject(&event) shouldEventually] beNonNil];
    [[event.data should] haveValue:@"bar" forKey:@"foo"];
  });
             
});

SPEC_END
