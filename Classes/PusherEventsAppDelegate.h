//
//  PusherEventsAppDelegate.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PusherEventsViewController;
@class PTPusher;

@interface PusherEventsAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  PusherEventsViewController *viewController;
  PTPusher *pusher;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PusherEventsViewController *viewController;
@property (nonatomic, retain) PTPusher *pusher;
@end

