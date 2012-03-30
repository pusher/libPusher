//
//  PusherEventsViewController.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherPresenceChannelDelegate.h"
#import "PTPusherDelegate.h"

@class PTPusher;
@class PTPusherPresenceChannel;


@interface PusherPresenceEventsViewController : UITableViewController <PTPusherDelegate, PTPusherPresenceChannelDelegate> {

}
@property (nonatomic) PTPusher *pusher;
@property (nonatomic) PTPusherPresenceChannel *currentChannel;

- (void)subscribeToPresenceChannel:(NSString *)channelName;
@end
