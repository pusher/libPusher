//
//  PTPusherPresenceChannelSpec.m
//  libPusher
//
//  Created by Luke Redpath on 28/03/2012.
//  Copyright 2012 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"

SPEC_BEGIN(PTPusherPresenceChannelSpec)

describe(@"PTPusherPresenceChannel", ^{
  __block PTPusherPresenceChannel *channel;
  
  beforeEach(^{
    channel = [[PTPusherPresenceChannel alloc] initWithName:@"presence-test-channel" pusher:nil];
  });
  
  it(@"starts off with no members", ^{
    [[channel.members should] beEmpty];
	});
  
  context(@"when a memberAdded event is received", ^{
    it(@"adds the member from the event to its members", ^{
      NSDictionary *eventData = [NSDictionary dictionaryWithObjectsAndKeys:@"123", @"user_id", [NSDictionary dictionaryWithObject:@"Joe Bloggs" forKey:@"name"], @"user_info", nil];
      
	    PTPusherEvent *event = [[PTPusherEvent alloc] initWithEventName:@"pusher_internal:member_added" channel:channel.name data:eventData];
      
      [channel dispatchEvent:event];
      
      [[theReturnValueOfBlock(^{ return theValue(channel.members.count); }) shouldEventually] equal:[NSNumber numberWithInt:1]];

      [[[channel.members[@"123"] userInfo][@"name"] should] equal:@"Joe Bloggs"];
    });
    
    it(@"adds an empty dictionary for the member if it has no info", ^{
      NSDictionary *eventData = [NSDictionary dictionaryWithObjectsAndKeys:@"123", @"user_id", nil];
      
	    PTPusherEvent *event = [[PTPusherEvent alloc] initWithEventName:@"pusher_internal:member_added" channel:channel.name data:eventData];
      
      [channel dispatchEvent:event];
      
      [[[channel.members[@"123"] userInfo] shouldEventually] equal:[NSDictionary dictionary]];
    });
  });
});

SPEC_END
