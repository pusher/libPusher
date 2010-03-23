//
//  PusherEventsViewController.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTPusher;

@interface PusherEventsViewController : UITableViewController {
  PTPusher *eventsPusher;
  NSMutableArray *eventsReceived;
}
@property (nonatomic, readonly) PTPusher *eventsPusher;
@property (nonatomic, readonly) NSMutableArray *eventsReceived;
@end

