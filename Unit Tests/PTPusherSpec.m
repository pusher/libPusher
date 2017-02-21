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
#import "SRWebSocket.h"

@interface PTPusherMockDelegate : NSObject <PTPusherDelegate>

@property (nonatomic, assign) BOOL didDisconnectWithErrorCalled;
@property (nonatomic, assign) BOOL willReconnect;

@end

@implementation PTPusherMockDelegate

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
  self.didDisconnectWithErrorCalled = YES;
  self.willReconnect = willAttemptReconnect;
}

@end

SPEC_BEGIN(PTPusherSpec)

describe(@"PTPusher", ^{
  
  __block PTPusher *pusher;
  __block PTPusherMockConnection *mockConnection;
  
  beforeEach(^{
    mockConnection = [[PTPusherMockConnection alloc] init];
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
  
  context(@"when the connection disconnects", ^{
    __block PTPusherMockDelegate *mockDelegate;
    
    beforeEach(^{
      mockDelegate = [PTPusherMockDelegate new];
      [[@(mockDelegate.willReconnect) should] beFalse];
      [[@(mockDelegate.didDisconnectWithErrorCalled) should] beFalse];
      
      pusher.delegate = mockDelegate;
    });
    
    it(@"does not attempt reconnection on SRStatusCodeNormal", ^{
      mockConnection.disconnectionCode = SRStatusCodeNormal;
      [pusher disconnect];
      
      [[@(mockDelegate.willReconnect) should] beFalse];
      [[@(mockDelegate.didDisconnectWithErrorCalled) should] beTrue];
    });
    
    it(@"does not attempt reconnection on SRStatusCodeGoingAway", ^{
      mockConnection.disconnectionCode = SRStatusCodeGoingAway;
      [pusher disconnect];
      
      [[@(mockDelegate.willReconnect) should] beFalse];
      [[@(mockDelegate.didDisconnectWithErrorCalled) should] beTrue];
    });
  });
});

SPEC_END
