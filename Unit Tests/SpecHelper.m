//
//  SpecHelper.m
//  libPusher
//
//  Created by Luke Redpath on 28/02/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"
#import "PTPusherEvent.h"

PTPusherEvent *anEventNamed(NSString *name) {
  return [[PTPusherEvent alloc] initWithEventName:name channel:@"any-channel" data:@"anything"];
}
