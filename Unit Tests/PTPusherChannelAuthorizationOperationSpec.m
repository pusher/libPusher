//
//  PTPusherChannelAuthorizationOperationSpec.m
//  libPusher
//
//  Created by Luke Redpath on 29/11/2012.
//
//

#import "SpecHelper.h"
#import "PTPusherChannelAuthorizationOperation.h"
#import "OHHTTPStubs.h"

SPEC_BEGIN(PTPusherChannelAuthorizationOperationSpec)

describe(@"PTPusherChannelAuthorizationOperation", ^{
  
  context(@"when a successful response is returned from the server", ^{
    __block PTPusherChannelAuthorizationOperation *theOperation;
    __block BOOL completionHandlerWasCalled = NO;
    
    beforeEach(^{
      NSURL *authURL = [NSURL URLWithString:@"http://example.com/authorize"];
      
      [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse *(NSURLRequest *request, BOOL onlyCheck) {
        return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{@"channel": @"test-channel"} options:0 error:nil]
                                          statusCode:200
                                        responseTime:OHHTTPStubsDownloadSpeedWifi
                                             headers:nil];
      }];
      
      theOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:authURL channelName:@"test-channel" socketID:@"test-socket"];
      theOperation.completionHandler = ^(PTPusherChannelAuthorizationOperation *operation) {
        completionHandlerWasCalled = YES;
      };
      
      [[NSOperationQueue mainQueue] addOperation:theOperation];
      
      [[theReturnValueOfBlock(^{ return @(theOperation.isFinished); }) shouldEventually] beTrue];
    });
    
    it(@"stores the parsed JSON authorization data", ^{
      [[theOperation.authorizationData should] equal:@{@"channel": @"test-channel"}];
    });
    
    it(@"is flagged as authorized", ^{
      [[@(theOperation.isAuthorized) should] beTrue];
    });
    
    it(@"calls the completion handler", ^{
	    [[@(completionHandlerWasCalled) should] beTrue];
    });
  });
  
});

SPEC_END
