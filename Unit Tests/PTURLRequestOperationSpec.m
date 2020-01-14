//
//  PTPusherSpec.m
//  libPusher
//
//  Created by Luke Redpath on 26/11/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SpecHelper.h"
#import "PTURLRequestOperation.h"


@interface PTURLRequestOperation ()

@property (nonatomic, weak, readwrite) id<NSURLSessionDelegate, NSURLSessionDataDelegate> delegate;

@end

@interface PTURLRequestOperationURLSessionDelegate ()

@property (nonatomic, weak, readwrite) id<NSURLSessionDelegate, NSURLSessionDataDelegate> delegate;

@end



@interface PTURLRequestOperationSpecs : XCTestCase

@property (nonatomic, strong) PTURLRequestOperation *subject;
@property (nonatomic, weak) PTURLRequestOperationURLSessionDelegate *sessionDelegate;
@property (nonatomic, weak) NSURLSession *session;

@end

@implementation PTURLRequestOperationSpecs

- (void)testFinishShouldInvalidateTheSessionDestroyingTheSessionDelegateOnDeallocation
{
  @autoreleasepool {
    NSURL *authURL = [NSURL URLWithString:@"http://example.com/authorize"];
    NSURLRequest *request = [NSURLRequest requestWithURL:authURL];
    self.subject = [[PTURLRequestOperation alloc] initWithURLRequest:request];
    [self.subject start];
    self.sessionDelegate = (PTURLRequestOperationURLSessionDelegate *)self.subject.URLSession.delegate;
    self.session = self.subject.URLSession;
  }
  
  // Nothing should be deallocated yet
  XCTAssertNotNil(self.sessionDelegate);
  XCTAssertNotNil(self.sessionDelegate.delegate);
  XCTAssertNotNil(self.subject);
  XCTAssertNotNil(self.session);
  
  [self.subject finish];
  
  // The `sessionDelegate.delegate` is now nil even despite the `subject` having not yet been deallocated
  XCTAssertNil(self.sessionDelegate.delegate);
  XCTAssertNotNil(self.subject);
  // Note the `session` and `sessionDelegate` are locked in a retain cycle (this is unavoidable)
  XCTAssertNotNil(self.session);
  XCTAssertNotNil(self.sessionDelegate);
  
  self.subject = nil;
  
  // The entities are now deallocated
  XCTAssertNil(self.sessionDelegate.delegate);
  XCTAssertNil(self.subject);
  // Note the `session` and `sessionDelegate` are locked in a retain cycle (this is unavoidable)
  XCTAssertNotNil(self.session);
  XCTAssertNotNil(self.sessionDelegate);
}

@end
