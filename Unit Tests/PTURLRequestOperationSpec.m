//
//  PTPusherSpec.m
//  libPusher
//
//  Created by Luke Redpath on 26/11/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SpecHelper.h"
#import "PTURLRequestOperation.h"

SPEC_BEGIN(PTPusherSpec)

describe(@"PTURLRequestOperation", ^{
  
  context(@"when it finishes", ^{
    __block PTURLRequestOperation *theOperation;
    
    beforeEach(^{
      NSURL *authURL = [NSURL URLWithString:@"http://example.com/authorize"];
      NSURLRequest *request = [NSURLRequest requestWithURL:authURL];
      theOperation = [[PTURLRequestOperation alloc] initWithURLRequest:request];
      [theOperation start];
      [[theOperation.URLSession shouldNot] beNil];
      [[theOperation.URLSession.delegate shouldNot] beNil];
      [theOperation finish];
    });
    
    it(@"should invalidate the session destroying the session delegate", ^{
      [[theOperation.URLSession.delegate should] beNil];
    });
  });
});

SPEC_END
