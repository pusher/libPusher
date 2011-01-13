//
//  PTPusherPresenseChannel.h
//  libPusher
//
//  Created by Juan Alvarez on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherChannel.h"
#import "PTPusherPrivateChannel.h"

extern NSString *const PTPusherPresenceChannelAuthPointException;
extern NSString *const PTPusherPresenceChannelInvalidNameException;

@interface PTPusherPresenseChannel : PTPusherPrivateChannel <PTPusherDelegate> {

}
- (id)initWithName:(NSString *)channelName 
			 appID:(NSString *)_id 
			   key:(NSString *)_key 
			secret:(NSString *)_secret 
		 authPoint:(NSURL *)_authPoint
		authParams:(NSDictionary *)_authParams
		  delegate:(id<PTPusherPrivateChannelDelegate,PTPusherChannelDelegate>)_delegate;
@end
