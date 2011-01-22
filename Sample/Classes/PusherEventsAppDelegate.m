//
//  PusherEventsAppDelegate.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherEventsAppDelegate.h"
#import "PusherEventsViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"

// this is not included in the source
// you must create this yourself and define PUSHER_API_KEY in it
#import "Constants.h" 

@implementation PusherEventsAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize eventsController;
@synthesize pusher;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
	[PTPusher setKey:PUSHER_API_KEY];
	[PTPusher setSecret:PUSHER_API_SECRET];
	[PTPusher setAppID:PUSHER_APP_ID];
	
	pusher = [[PTPusher alloc] initWithKey:PUSHER_API_KEY];
	pusher.delegate = self;
	pusher.reconnect = YES;
	
	[pusher addEventListener:@"test-global-event" block:^(PTPusherEvent *event) {
		NSLog(@"Received Block Event!! : %@", [event description]);
	}];
	
//	PTPusherChannel *channel = [pusher subscribeToChannel:@"test-channel" withAuthPoint:nil];
//	channel.delegate = self;
	
	PTPusherChannel *privateChannel = [pusher subscribeToChannel:@"private-my-channel" withAuthPoint:[NSURL URLWithString:@"http://localhost:3000/pusher/private_auth"]];
	privateChannel.delegate = self;
	
//	PTPusherChannel *presenceChannel = [pusher subscribeToChannel:@"presence-my-channel" withAuthPoint:[NSURL URLWithString:@"http://localhost:3000/pusher/presence_auth"]];
//	presenceChannel.delegate = self;
	
	eventsController.eventsChannel = privateChannel;
	
	eventsController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Unsubscribe" style:UIBarButtonItemStyleBordered target:self action:@selector(unsubscribe:)] autorelease];

	[window addSubview:navigationController.view];
	[window makeKeyAndVisible];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PTPusherEventReceivedNotification object:pusher];

	[pusher release];
	[navigationController release];
	[window release];
	[eventsController release];
	
	[super dealloc];
}

- (void)unsubscribe:(id)sender
{
	PTPusherChannel *channel = [pusher channelWithName:@"test-channel"];
	[pusher unsubscribeFromChannel:channel];
}

#pragma mark -
#pragma mark Channel Delegate

- (void)channel:(PTPusherChannel *)channel didReceiveEvent:(PTPusherEvent *)event
{
//	NSLog([event description], nil);
}

#pragma mark -
#pragma mark Private/Presence Channel Delegate

- (NSDictionary *)extraParamsForChannelAuthentication:(PTPusherChannel *)channel
{
	// This is for sending additional parameters to Authentication server for further validation
	return nil;
}

- (BOOL)privateChannelShouldContinueWithAuthResponse:(NSData *)data
{
	// This method should check the response from the Authentication server and see if it's valid
	return YES;
}

#pragma mark -
#pragma mark Presence Channel Delegate

- (void)presenceChannelSubscriptionSucceeded:(PTPusherChannel *)channel withUserInfo:(NSDictionary *)userInfo
{
	NSLog(@"pusher:subscription_succeeded received:\n%@", [userInfo description]);
}

- (void)presenceChannel:(PTPusherChannel *)channel memberAdded:(NSDictionary *)memberInfo
{
	NSLog(@"pusher:member_added received:\n%@", [memberInfo description]);
}

- (void)presenceChannel:(PTPusherChannel *)channel memberRemoved:(NSDictionary *)memberInfo
{
	NSLog(@"pusher:member_removed received:\n%@", [memberInfo description]);
}

#pragma mark -
#pragma mark Private Channel Delegate

- (void)channelAuthenticationStarted:(PTPusherChannel *)channel
{
	NSLog(@"Private Channel Authentication Started: %@", channel.name);
}

- (void)channelAuthenticationFailed:(PTPusherChannel *)channel withError:(NSError *)error
{
	NSLog(@"Private Channel Authentication Failed: %@", channel.name);
}

#pragma mark -
#pragma mark PTPusherDelegate methods

- (void)pusherWillConnect:(PTPusher *)_pusher;
{
	NSLog(@"Pusher %@ connecting...", _pusher);
}

- (void)pusherDidConnect:(PTPusher *)_pusher;
{
	NSLog(@"Pusher %@ connected", _pusher);
}

- (void)pusherDidDisconnect:(PTPusher *)_pusher;
{
	NSLog(@"Pusher %@ disconnected", _pusher);
}

- (void)pusherDidFailToConnect:(PTPusher *)_pusher withError:(NSError *)error;
{
	NSLog(@"Pusher %@ failed with error %@", _pusher, error);
}

- (void)pusherWillReconnect:(PTPusher *)_pusher afterDelay:(NSUInteger)delay;
{
	NSLog(@"Pusher %@ will reconnect after %d seconds", _pusher, delay);
}

@end
