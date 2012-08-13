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
      
      [[theReturnValueOfBlock(^{ return theValue(channel.memberCount); }) shouldEventually] equal:[NSNumber numberWithInt:1]];

      [[channel.memberIDs should] contain:@"123"];
      [[[[channel infoForMemberWithID:@"123"] objectForKey:@"name"] should] equal:@"Joe Bloggs"];
    });
    
    it(@"adds an empty dictionary for the member if it has no info", ^{
      NSDictionary *eventData = [NSDictionary dictionaryWithObjectsAndKeys:@"123", @"user_id", nil];
      
	    PTPusherEvent *event = [[PTPusherEvent alloc] initWithEventName:@"pusher_internal:member_added" channel:channel.name data:eventData];
      
      [channel dispatchEvent:event];
      
      [[[channel infoForMemberWithID:@"123"] shouldEventually] equal:[NSDictionary dictionary]];
    });
  });
});

SPEC_END
