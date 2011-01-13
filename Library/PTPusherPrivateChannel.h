//
//  PTPusherPrivateChannel.h
//  libPusher
//
//  Created by Juan Alvarez on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherChannel.h"
#import "PTPusherPrivateChannelDelegate.h"

extern NSString *const PTPusherPrivateChannelAuthPointException;

@interface PTPusherPrivateChannel : PTPusherChannel <PTPusherDelegate> {
	NSURL *authPointURL;
	NSDictionary *authParams;
}
@property (nonatomic, retain) NSURL *authPointURL;
@property (nonatomic, retain) NSDictionary *authParams;

- (id)initWithName:(NSString *)channelName 
			 appID:(NSString *)_id 
			   key:(NSString *)_key 
			secret:(NSString *)_secret 
		 authPoint:(NSURL *)_authPoint
		authParams:(NSDictionary *)_authParams
		  delegate:(id<PTPusherPrivateChannelDelegate,PTPusherChannelDelegate>)_delegate;

@end
