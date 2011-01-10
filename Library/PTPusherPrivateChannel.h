//
//  PTPusherPrivateChannel.h
//  libPusher
//
//  Created by Juan Alvarez on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

extern NSString *const PTPusherPrivateChannelAuthPointException;

#import <Foundation/Foundation.h>
#import "PTPusherChannel.h"

@interface PTPusherPrivateChannel : PTPusherChannel <PTPusherDelegate> {
	NSURL *authPointURL;
}
@property (nonatomic, retain) NSURL *authPointURL;

- (id)initWithName:(NSString *)channelName 
			 appID:(NSString *)_id 
			   key:(NSString *)_key 
			secret:(NSString *)_secret 
		 authPoint:(NSURL *)_authPoint;

@end
