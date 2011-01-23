//
//  PusherPresenceViewController.h
//  libPusher
//
//  Created by Juan Alvarez on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTPusher;
#import "PTPusherChannel.h"

@interface PusherPresenceViewController : UITableViewController <PTPusherChannelDelegate> {
	NSMutableArray *members;
	
	PTPusher *pusher;
	PTPusherChannel *presenceChannel;
}
@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) PTPusher *pusher;
@property (nonatomic, retain) PTPusherChannel *presenceChannel;

+ (PusherPresenceViewController *)controller;
@end
