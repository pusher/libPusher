//
//  PusherEventsViewController.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherChannelDelegate.h"

@class PTPusherChannel;

@protocol PusherEventsDelegate
- (void)sendEventWithMessage:(NSString *)message;
@end

@interface PusherEventsViewController : UITableViewController <PusherEventsDelegate, PTPusherChannelDelegate> {
  PTPusherChannel *eventsChannel;
  NSMutableArray *eventsReceived;
}
@property (nonatomic, readonly) PTPusherChannel *eventsChannel;
@property (nonatomic, readonly) NSMutableArray *eventsReceived;
@end
