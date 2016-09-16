//
//  PusherEventsAppDelegate.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherDelegate.h"

@class PusherExampleMenuViewController;
@class PTPusher;

@interface PusherEventsAppDelegate : NSObject <UIApplicationDelegate, PTPusherDelegate>

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet UINavigationController *navigationController;
@property (nonatomic) IBOutlet PusherExampleMenuViewController *menuViewController;
@property (nonatomic, strong) PTPusher *pusherClient;

@end

