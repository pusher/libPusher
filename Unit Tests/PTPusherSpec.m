//
//  PTPusherSpec.m
//  libPusher
//
//  Created by Luke Redpath on 26/11/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SpecHelper.h"
#import "PTPusher.h"
#import "PTPusherMockConnection.h"

SPEC_BEGIN(PTPusherSpec)

describe(@"PTPusher", ^{
  
  __block PTPusher *pusher;
  __block PTPusherConnection *mockConnection = [[PTPusherMockConnection alloc] init];
  
  beforeEach(^{
    pusher = [[PTPusher alloc] initWithConnection:mockConnection];
  });
  
  it(@"it allows the reconnectDelay to be configured but not less than 1 second", ^{
    pusher.reconnectDelay = 1;
    [[@(pusher.reconnectDelay) should] equal:@1];
    
    pusher.reconnectDelay = 5;
    [[@(pusher.reconnectDelay) should] equal:@5];
    
    pusher.reconnectDelay = 0;
    [[@(pusher.reconnectDelay) should] equal:@1];
	});
  
});

SPEC_END
