//
//  PusherEventsViewController.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTPusher;
@class PTPusherChannel;

@protocol PusherEventsDelegate
- (void)sendEventWithMessage:(NSString *)message;
@end

@interface PusherEventsViewController : UITableViewController <PusherEventsDelegate> {
  PTPusher *eventsPusher;
  PTPusherChannel *pusherClient;
  NSMutableArray *eventsReceived;
}
@property (nonatomic, readonly) PTPusher *eventsPusher;
@property (nonatomic, readonly) PTPusherChannel *pusherClient;
@property (nonatomic, readonly) NSMutableArray *eventsReceived;
@end
