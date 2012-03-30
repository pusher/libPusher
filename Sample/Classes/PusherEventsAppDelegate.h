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
@class PTPusherConnectionMonitor;

@interface PusherEventsAppDelegate : NSObject <UIApplicationDelegate, PTPusherDelegate> {
  NSMutableArray *connectedClients;
  NSMutableArray *clientsAwaitingConnection;
}
@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet UINavigationController *navigationController;
@property (nonatomic) IBOutlet PusherExampleMenuViewController *menuViewController;
@property (nonatomic, strong) PTPusher *pusher;
@property (nonatomic, strong) PTPusherConnectionMonitor *connectionMonitor;

- (PTPusher *)lastConnectedClient;
- (PTPusher *)createClientWithAutomaticConnection:(BOOL)connectAutomatically;
@end

