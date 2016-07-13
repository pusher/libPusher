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
@class PTPusherAPI;

@protocol PusherEventsDelegate
- (void)sendEventWithMessage:(NSString *)message;
@end

@interface PusherEventsViewController : UITableViewController <PusherEventsDelegate> {
  NSMutableArray *eventsReceived;
}
@property (nonatomic) PTPusher *pusher;
@property (nonatomic) PTPusherAPI *pusherAPI;
@property (nonatomic) PTPusherChannel *currentChannel;
@property (nonatomic, readonly) NSMutableArray *eventsReceived;

- (void)subscribeToChannel:(NSString *)channelName;
@end
