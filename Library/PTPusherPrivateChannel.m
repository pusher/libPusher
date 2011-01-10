//
//  PTPusherPrivateChannel.m
//  libPusher
//
//  Created by Juan Alvarez on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PTPusherPrivateChannel.h"
#import "PTPusher.h"

NSString* const PTPusherPrivateChannelAuthPointException = @"PTPusherPrivateChannelAuthPointException";

@implementation PTPusherPrivateChannel

@synthesize authPointURL;

- (id)initWithName:(NSString *)channelName 
			 appID:(NSString *)_id 
			   key:(NSString *)_key 
			secret:(NSString *)_secret 
		 authPoint:(NSURL *)_authPoint;
{
	if ([channelName rangeOfString:@"private" options:NSCaseInsensitiveSearch].location == NSNotFound)
		channelName = [NSString stringWithFormat:@"private-%@", channelName];
	
	if (self = [super initWithName:channelName appID:_id key:_key secret:_secret]) {
		if (_authPoint == nil)
			[NSException raise:PTPusherPrivateChannelAuthPointException format:@"Authentication URL should not be nil"];
		
		self.authPointURL = _authPoint;
	}
	
	return self;
}

- (void)dealloc
{
	[authPointURL release];
	
	[super dealloc];
}

//- (void)startListeningForEvents;
//{
//	[pusher release];
//	pusher = [[PTPusher alloc] initWithKey:APIKey channel:name];
//	pusher.delegate = self;
//	pusher.reconnect = YES;
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedEventNotification:) name:PTPusherEventReceivedNotification object:nil];
//}
//
//- (void)stopListeningForEvents;
//{
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:PTPusherEventReceivedNotification object:nil];
//	[pusher release];
//	pusher = nil;
//}

#pragma mark -
#pragma mark Private

- (void)authenticateWithSocketID:(NSInteger)_socketID
{	
	NSString *paramsURL = [NSString stringWithFormat:@"%@?channel_name=%@&socket_id=%i", [authPointURL absoluteString], name, _socketID];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paramsURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded; charset=\"UTF-8\"" forHTTPHeaderField:@"Content-Type"];
	
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	[connection start];
}

- (void)receivedEventNotification:(NSNotification *)note;
{
	PTPusherEvent *event = (PTPusherEvent *)note.object;
	
	if ([event.name isEqualToString:@"connection_established"]) {
		NSInteger _socketid = pusher.socketID;
		
	} else {
		[super receivedEventNotification:note];
	}
}


@end
