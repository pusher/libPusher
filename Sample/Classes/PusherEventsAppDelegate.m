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
#import "PTPusherPrivateChannel.h"
#import "PTPusherPresenseChannel.h"

// this is not included in the source
// you must create this yourself and define PUSHER_API_KEY in it
#import "Constants.h" 

@implementation PusherEventsAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize pusher;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
	[PTPusher setKey:PUSHER_API_KEY];
	[PTPusher setSecret:PUSHER_API_SECRET];
	[PTPusher setAppID:PUSHER_APP_ID];
	
//	pusher = [[PTPusher alloc] initWithKey:PUSHER_API_KEY channel:@"test-channel"];
//	pusher.delegate = self;
//
//	//uncomment to allow reconnections
//	pusher.reconnect = YES;
	
//	[pusher addEventListener:@"alert" target:self selector:@selector(handleAlertEvent:)];
	
//	privateEventsChannel = [PTPusher newPrivateChannel:@"private-my-channel" authPoint:[NSURL URLWithString:@"http://localhost:3000/pusher/private_auth"] authParams:nil];
//	privateEventsChannel.delegate = self;
//	[privateEventsChannel startListeningForEvents];
	
	presenseEventsChannel = [PTPusher newPresenceChannel:@"presence-my-channel" authPoint:[NSURL URLWithString:@"http://localhost:3000/pusher/presence_auth"] authParams:[NSDictionary dictionaryWithObject:@"1" forKey:@"id"]];
	presenseEventsChannel.delegate = self;
	[presenseEventsChannel startListeningForEvents];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:nil];

	[window addSubview:navigationController.view];
	[window makeKeyAndVisible];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PTPusherEventReceivedNotification object:pusher];
	[pusher release];
	[navigationController release];
	[window release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark PTPusherPresenseChannel Delegate

- (void)presenceChannelSubscriptionSucceeded:(PTPusherPresenseChannel *)channel withUserInfo:(NSDictionary *)userInfo
{
	NSLog(@"pusher:subscription_succeeded received:\n%@", [userInfo description]);
}

- (void)presenceChannel:(PTPusherPresenseChannel *)channel memberAdded:(NSDictionary *)memberInfo
{
	NSLog(@"pusher:member_added received:\n%@", [memberInfo description]);
}

- (void)presenceChannel:(PTPusherPresenseChannel *)channel memberRemoved:(NSDictionary *)memberInfo
{
	NSLog(@"pusher:member_removed received:\n%@", [memberInfo description]);
}

#pragma mark -
#pragma mark PTPusherPrivateChannel Delegate

- (BOOL)privateChannelShouldContinueWithAuthResponse:(NSData *)data
{
	// This method should check the response from the Authentication server and check to see if it's valid
	return YES;
}

- (void)privateChannelAuthenticationStarted:(PTPusherPrivateChannel *)channel
{
	NSLog(@"Private Channel Authentication Started: %@", channel.name);
}
- (void)privateChannelAuthenticated:(PTPusherPrivateChannel *)channel
{
	NSLog(@"Private Channel Authenticated: %@", channel.name);
}
- (void)privateChannelAuthenticationFailed:(PTPusherPrivateChannel *)channel withError:(NSError *)error
{
	NSLog(@"Private Channel Authentication Failed: %@", channel.name);
}

#pragma mark -
#pragma mark Sample Pusher event handlers

// specific alert handler, handle events using target/selector dispatch
- (void)handleAlertEvent:(PTPusherEvent *)event;
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[event.data valueForKey:@"title"] message:[event.data valueForKey:@"message"] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

// generic alert handler, handle all events using NSNotifications
- (void)handlePusherEvent:(NSNotification *)note;
{
	NSLog(@"Received event: %@", note.object);
}

#pragma mark -
#pragma mark UIAlertView delegate methods

- (void)didPresentAlertView:(UIAlertView *)alertView
{
	[self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:1];
}

- (void)dismissAlertView:(UIAlertView *)alertView;
{
	[alertView dismissWithClickedButtonIndex:0 animated:YES];
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
