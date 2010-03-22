//
//  PTWebSocket.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTWebSocket.h"


@implementation PTWebSocket

@synthesize URL;

- (id)initWithURL:(NSURL *)_URL;
{
  return [self initWithURL:_URL protocol:nil];
}

- (id)initWithURL:(NSURL *)_URL protocol:(NSString *)_protocol;
{
  if (self = [super init]) {
    URL = [_URL copy];
    protocol = [_protocol copy];
  }
  return self;
}

- (void)dealloc;
{
  [URL release];
  [protocol release];
  [super dealloc];
}

#pragma mark -

- (void)send:(NSString *)data;
{
  
}

- (void)close;
{
  
}

@end
