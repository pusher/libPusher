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
      
      [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:authURL];
        
      } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{@"channel": @"test-channel"} options:0 error:nil]
                                          statusCode:200
                                             headers:nil];
      }];
      
      theOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:authURL channelName:@"test-channel" socketID:@"test-socket"];
      theOperation.completionHandler = ^(PTPusherChannelAuthorizationOperation *operation) {
        completionHandlerWasCalled = YES;
      };
      
      [[NSOperationQueue mainQueue] addOperation:theOperation];
      
      [[expectFutureValue(@(theOperation.isFinished)) shouldEventually] beTrue];
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
  
  context(@"when a non-successful response is returned from the server", ^{
    __block PTPusherChannelAuthorizationOperation *theOperation;
    __block BOOL completionHandlerWasCalled = NO;
    
    beforeEach(^{
      NSURL *authURL = [NSURL URLWithString:@"http://example.com/authorize"];
      
      [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:authURL];
        
      } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:400
                                             headers:nil];
      }];
      
      theOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:authURL channelName:@"test-channel" socketID:@"test-socket"];
      theOperation.completionHandler = ^(PTPusherChannelAuthorizationOperation *operation) {
        completionHandlerWasCalled = YES;
      };
      
      [[NSOperationQueue mainQueue] addOperation:theOperation];
      
      [[expectFutureValue(@(theOperation.isFinished)) shouldEventually] beTrue];
    });
    
    it(@"has no authorization data", ^{
	    [[expectFutureValue(theOperation.authorizationData) should] beNil];
    });
    
    it(@"is not flagged as authorized", ^{
	    [[@(theOperation.isAuthorized) should] beFalse];
    });
    
    it(@"calls the completion handler", ^{
	    [[@(completionHandlerWasCalled) should] beTrue];
    });
  });
  
  context(@"when a successful response is returned from the server without any authorization data", ^{
    __block PTPusherChannelAuthorizationOperation *theOperation;
    __block BOOL completionHandlerWasCalled = NO;
    
    beforeEach(^{
      NSURL *authURL = [NSURL URLWithString:@"http://example.com/authorize"];
      
      [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:authURL];
        
      } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:200
                                             headers:nil];
      }];
      
      theOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:authURL channelName:@"test-channel" socketID:@"test-socket"];
      theOperation.completionHandler = ^(PTPusherChannelAuthorizationOperation *operation) {
        completionHandlerWasCalled = YES;
      };
      
      [[NSOperationQueue mainQueue] addOperation:theOperation];
      
      [[expectFutureValue(@(theOperation.isFinished)) shouldEventually] beTrue];
    });
    
    it(@"has no authorization data", ^{
	    [[expectFutureValue(theOperation.authorizationData) should] beNil];
    });
    
    it(@"is flagged as not authorized", ^{
	    [[@(theOperation.isAuthorized) should] beFalse];
    });
    
    it(@"has a PTPusherChannelAuthorizationBadResponseError error", ^{
	    [[@(theOperation.error.code) should] equal:@(PTPusherChannelAuthorizationBadResponseError)];
    });
    
    it(@"calls the completion handler", ^{
	    [[@(completionHandlerWasCalled) should] beTrue];
    });
  });
  
  context(@"when a successful response is returned from the server with malformed JSON data", ^{
    __block PTPusherChannelAuthorizationOperation *theOperation;
    __block BOOL completionHandlerWasCalled = NO;
    
    beforeEach(^{
      NSURL *authURL = [NSURL URLWithString:@"http://example.com/authorize"];
      
      [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:authURL];
        
      } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[@"{malformed json" dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:200
                                             headers:nil];
      }];
      
      theOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:authURL channelName:@"test-channel" socketID:@"test-socket"];
      theOperation.completionHandler = ^(PTPusherChannelAuthorizationOperation *operation) {
        completionHandlerWasCalled = YES;
      };
      
      [[NSOperationQueue mainQueue] addOperation:theOperation];
      
      [[expectFutureValue(@(theOperation.isFinished)) shouldEventually] beTrue];
    });
    
    it(@"has no authorization data", ^{
	    [[expectFutureValue(theOperation.authorizationData) should] beNil];
    });
    
    it(@"is flagged as not authorized", ^{
	    [[@(theOperation.isAuthorized) should] beFalse];
    });
    
    it(@"has a PTPusherChannelAuthorizationBadResponseError error", ^{
	    [[@(theOperation.error.code) should] equal:@(PTPusherChannelAuthorizationBadResponseError)];
    });
    
    it(@"calls the completion handler", ^{
	    [[@(completionHandlerWasCalled) should] beTrue];
    });
  });
  
  context(@"when the connection fails", ^{
    __block PTPusherChannelAuthorizationOperation *theOperation;
    __block BOOL completionHandlerWasCalled = NO;
    
    beforeEach(^{
      NSURL *authURL = [NSURL URLWithString:@"http://example.com/authorize"];
      
      [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:authURL];
        
      } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotFindHost userInfo:nil]];
      }];
      
      theOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:authURL channelName:@"test-channel" socketID:@"test-socket"];
      theOperation.completionHandler = ^(PTPusherChannelAuthorizationOperation *operation) {
        completionHandlerWasCalled = YES;
      };
      
      [[NSOperationQueue mainQueue] addOperation:theOperation];
      
      [[expectFutureValue(@(theOperation.isFinished)) shouldEventually] beTrue];
    });
    
    it(@"has no authorization data", ^{
	    [[expectFutureValue(theOperation.authorizationData) should] beNil];
    });
    
    it(@"is flagged as not authorized", ^{
	    [[@(theOperation.isAuthorized) should] beFalse];
    });
    
    it(@"has a PTPusherChannelAuthorizationConnectionError error", ^{
	    [[@(theOperation.error.code) should] equal:@(PTPusherChannelAuthorizationConnectionError)];
    });
    
    it(@"stores the underlying network error in the operation error", ^{
      NSError *underlyingError = [theOperation.error.userInfo objectForKey:NSUnderlyingErrorKey];
      [[underlyingError.domain should] equal:NSURLErrorDomain];
    });
    
    it(@"calls the completion handler", ^{
	    [[@(completionHandlerWasCalled) should] beTrue];
    });
  });
});

SPEC_END
