//
//  PusherEventsViewController.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherChannelDelegate.h"
#import "PTPusherDelegate.h"

@class PTPusher;
@class PTPusherChannel;

@protocol PusherEventsDelegate
- (void)sendEventWithMessage:(NSString *)message;
@end

@interface PusherEventsViewController : UITableViewController <PusherEventsDelegate, PTPusherDelegate, PTPusherChannelDelegate> {
	PTPusher *pusher;
	PTPusherChannel *eventsChannel;
	
	NSMutableArray *eventsReceived;
}
@property (nonatomic, retain) PTPusher *pusher;
@property (nonatomic, retain) PTPusherChannel *eventsChannel;
@property (nonatomic, readonly) NSMutableArray *eventsReceived;

+ (PusherEventsViewController *)controller;

@end
