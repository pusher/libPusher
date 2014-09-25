//
//  PTPusherPresenceChannelSpec.m
//  libPusher
//
//  Created by Luke Redpath on 28/03/2012.
//  Copyright 2012 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"
#import "PTPusherChannel.h"
#import "PTPusherChannel_Private.h"
#import "PTPusherEvent.h"
#import "PTJSON.h"

SPEC_BEGIN(PTPusherPresenceChannelSpec)

describe(@"PTPusherPresenceChannel", ^{
  __block PTPusherPresenceChannel *channel;
  
  beforeEach(^{
    channel = [[PTPusherPresenceChannel alloc] initWithName:@"presence-test-channel" pusher:nil];
  });
  
  it(@"starts off with no members", ^{
    [[channel.members should] beEmpty];
	});
  
  it(@"stores a reference to the subscriber's user ID on authorization", ^{
    NSDictionary *authData = @{@"channel_data": [[PTJSON JSONParser] JSONStringFromObject:@{@"user_id": @"12345"}]};
    [channel subscribeWithAuthorization:authData];
    [[channel.members.myID should] equal:@"12345"];
	});
  
  it(@"updates the member list on subscribe", ^{
    NSDictionary *subscribeEventData = @{@"presence": @{
      @"count": @1,
      @"hash": @{
          @"user-1": @{@"name": @"Joe"}
      }
    }};

    PTPusherEvent *subscribeEvent = [[PTPusherEvent alloc] initWithEventName:@"pusher_internal:subscription_succeeded" channel:channel.name data:subscribeEventData];
    [channel dispatchEvent:subscribeEvent];
    
    [[expectFutureValue(@(channel.members.count)) shouldEventually] equal:@1];
	});
  
  it(@"can return the subscribed member after authorising and subscribing", ^{
    NSDictionary *authData = @{@"channel_data": [[PTJSON JSONParser] JSONStringFromObject:@{@"user_id": @"user-1"}]};
    [channel subscribeWithAuthorization:authData];
    
    NSDictionary *subscribeEventData = @{@"presence": @{
      @"count": @1,
      @"hash": @{
          @"user-1": @{@"name": @"Joe"}
      }
    }};

    PTPusherEvent *subscribeEvent = [[PTPusherEvent alloc] initWithEventName:@"pusher_internal:subscription_succeeded" channel:channel.name data:subscribeEventData];
    [channel dispatchEvent:subscribeEvent];
    
    [[expectFutureValue(channel.members.me) shouldEventually] haveValue:@"user-1" forKey:@"userID"];
	});
  
  it(@"handles member_added events", ^{
    NSDictionary *eventData = @{@"user_id": @"123", @"user_info": @{@"name": @"Joe Bloggs"}};
    
    PTPusherEvent *event = [[PTPusherEvent alloc] initWithEventName:@"pusher_internal:member_added" channel:channel.name data:eventData];
    [channel dispatchEvent:event];
    
    [[expectFutureValue(@(channel.members.count)) shouldEventually] equal:@1];
    [[[channel.members[@"123"] userInfo][@"name"] should] equal:@"Joe Bloggs"];
  });
  
  it(@"handles member_removed events", ^{
    PTPusherEvent *memberAddedEvent = [[PTPusherEvent alloc] initWithEventName:@"pusher_internal:member_added" channel:channel.name data:@{@"user_id": @"123", @"user_info": @{@"name": @"Joe Bloggs"}}];
    [channel dispatchEvent:memberAddedEvent];
    
    [[expectFutureValue(@(channel.members.count)) shouldEventually] equal:@1];
    
    PTPusherEvent *memberRemovedEvent = [[PTPusherEvent alloc] initWithEventName:@"pusher_internal:member_removed" channel:channel.name data:@{@"user_id": @"123"}];
    [channel dispatchEvent:memberRemovedEvent];
    
    [[expectFutureValue(@(channel.members.count)) shouldEventually] equal:@0];
    
    [[channel.members[@"123"] should] beNil];
  });
});

SPEC_END
