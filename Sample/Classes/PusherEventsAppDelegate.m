//
//  PusherEventsAppDelegate.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherEventsAppDelegate.h"

#import "PusherEventsViewController.h"
#import "PusherPresenceViewController.h"

#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"

// this is not included in the source
// you must create this yourself and define PUSHER_API_KEY in it
#import "Constants.h" 

@implementation PusherEventsAppDelegate

@synthesize window;
@synthesize tabController;
@synthesize eventsController, presenceController;
@synthesize pusher;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
	[PTPusher setKey:PUSHER_API_KEY];
	[PTPusher setSecret:PUSHER_API_SECRET];
	[PTPusher setAppID:PUSHER_APP_ID];
	
	pusher = [[PTPusher alloc] initWithKey:PUSHER_API_KEY delegate:self];
	pusher.reconnect = YES;
	
	[pusher addEventListener:@"test-global-event" block:^(PTPusherEvent *event) {
		NSLog(@"Received Global Event!! : %@", [event description]);
	}];
	
	self.eventsController = [PusherEventsViewController controller];
	self.eventsController.pusher = pusher;
	self.presenceController = [PusherPresenceViewController controller];
	self.presenceController.pusher = pusher;
	
	UINavigationController *eventsNav = [[[UINavigationController alloc] initWithRootViewController:eventsController] autorelease];
	UINavigationController *presenceNav = [[[UINavigationController alloc] initWithRootViewController:presenceController] autorelease];
	
	NSArray *controllers = [NSArray arrayWithObjects:presenceNav, eventsNav, nil];
	
	tabController.viewControllers = controllers;
	
	[window addSubview:tabController.view];
	[window makeKeyAndVisible];
}

- (void)dealloc 
{
	[tabController release];
	[window release];
	
	[eventsController release];
	[presenceController release];
	
	[pusher release];
	
	[super dealloc];
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

- (void)presenceChannelSubscriptionSucceeded:(PTPusherChannel *)channel withUserInfo:(NSArray *)userList
{
	NSLog(@"pusher:subscription_succeeded received:\n%@", [userList description]);
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
