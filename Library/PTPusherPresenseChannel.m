//
//  PTPusherPresenseChannel.m
//  libPusher
//
//  Created by Juan Alvarez on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PTPusherPresenseChannel.h"


@implementation PTPusherPresenseChannel

- (id)initWithName:(NSString *)channelName 
			 appID:(NSString *)_id 
			   key:(NSString *)_key 
			secret:(NSString *)_secret 
		 authPoint:(NSURL *)_authPoint
		  delegate:(id<PTPusherPrivateChannelDelegate,PTPusherChannelDelegate>)_delegate
{
	if ([channelName rangeOfString:@"presence-" options:NSCaseInsensitiveSearch].location == NSNotFound)
		channelName = [NSString stringWithFormat:@"presence-%@", channelName];
	
	if (self = [super initWithName:channelName appID:_id key:_key secret:_secret]) {
		if (_authPoint == nil)
			[NSException raise:PTPusherPrivateChannelAuthPointException format:@"Authentication URL should not be nil"];
		
		self.delegate = _delegate;
		self.authPointURL = _authPoint;
	}
	
	return self;
}

- (void)receivedEventNotification:(NSNotification *)note;
{
	PTPusherEvent *event = (PTPusherEvent *)note.object;
	NSLog(@"%@", event);
	
	if ([event.name isEqualToString:@"pusher:subscription_succeeded"]) {
		
	}
	
	else if ([event.name isEqualToString:@"pusher:member_added"]) {
		
	}
	
	else if ([event.name isEqualToString:@"pusher:member_removed"]) {
		
	}
}

@end
