//
//  PTPusherChannelDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTPusherChannel;
@class PTPusherEvent;

@protocol PTPusherChannelDelegate <NSObject>

@optional
- (void)channel:(PTPusherChannel *)channel didReceiveEvent:(PTPusherEvent *)event;

@end
