//
//  PusherEventsAppDelegate.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherDelegate.h"
#import "PTPusherChannelDelegate.h"

@class PusherEventsViewController;
@class PusherPresenceViewController;
@class PTPusher;

@interface PusherEventsAppDelegate : NSObject <UIApplicationDelegate, PTPusherDelegate, PTPusherChannelDelegate> {
	UIWindow *window;
	UITabBarController *tabController;
	
	PusherEventsViewController *eventsController;
	PusherPresenceViewController *presenceController;
	PTPusher *pusher;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabController;

@property (nonatomic, retain) PusherEventsViewController *eventsController;
@property (nonatomic, retain) PusherPresenceViewController *presenceController;
@property (nonatomic, retain) PTPusher *pusher;

@end

