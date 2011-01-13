//
//  PTPusherPresenseChannel.m
//  libPusher
//
//  Created by Juan Alvarez on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PTPusherPresenseChannel.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"

NSString* const PTPusherPresenceChannelAuthPointException = @"PTPusherPrivateChannelAuthPointException";
NSString* const PTPusherPresenceChannelInvalidNameException = @"PTPusherPrivateChannelInvalidNameException";

@implementation PTPusherPresenseChannel

- (id)initWithName:(NSString *)channelName 
			 appID:(NSString *)_id 
			   key:(NSString *)_key 
			secret:(NSString *)_secret 
		 authPoint:(NSURL *)_authPoint
		authParams:(NSDictionary *)_authParams
		  delegate:(id<PTPusherPrivateChannelDelegate,PTPusherChannelDelegate>)_delegate
{
	if ([channelName rangeOfString:kPresenseChannelPrefix options:NSCaseInsensitiveSearch].location == NSNotFound)
		[NSException raise:PTPusherPresenceChannelInvalidNameException format:@"Presence channel name must be prefixed with presence-"];
	
	if (self = [super initWithName:channelName appID:_id key:_key secret:_secret]) {
		if (_authPoint == nil)
			[NSException raise:PTPusherPresenceChannelAuthPointException format:@"Authentication URL should not be nil for Presence channel"];
		
		self.delegate = _delegate;
		self.authPointURL = _authPoint;
		self.authParams = _authParams;
	}
	
	return self;
}

- (void)receivedEventNotification:(NSNotification *)note;
{
	PTPusherEvent *event = (PTPusherEvent *)note.object;
	
	if ([event.name isEqualToString:@"pusher:subscription_succeeded"]) {
		NSLog(@"pusher:subscription_succeeded received:\n%@", [event description]);
	}
	
	else if ([event.name isEqualToString:@"pusher:member_added"]) {
		NSLog(@"pusher:member_added received:\n%@", [event description]);
	}
	
	else if ([event.name isEqualToString:@"pusher:member_removed"]) {
		NSLog(@"pusher:member_removed received:\n%@", [event description]);
	}
	
	else {
		[super receivedEventNotification:note];
	}

}

@end
