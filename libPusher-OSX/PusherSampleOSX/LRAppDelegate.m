//
//  LRAppDelegate.m
//  PusherSampleOSX
//
//  Created by Luke Redpath on 05/02/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "LRAppDelegate.h"
#import "Constants.h"
#import <Pusher/PTPusher.h>
#import <Pusher/PTPusherChannel.h>
#import <Pusher/PTPusherEvent.h>

@implementation LRAppDelegate

@synthesize window = _window;
@synthesize eventsTableView = _eventsTableView;
@synthesize events = _events;
@synthesize eventsController = _eventsController;
@synthesize connectionStatus = _connectionStatus;
@synthesize pusher;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  _events = [[NSMutableArray alloc] init];
}

- (IBAction)connect:(id)sender 
{
  [sender setEnabled:NO];
  
  self.pusher = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:NO];

  [[self.pusher subscribeToChannelNamed:@"messages"] bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *event) {
    [self.eventsController addObject:event];
  }];
}

#pragma mark - PTPusherEventDelegate methods

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
  NSLog(@"Connected!");
  [self.connectionStatus setStringValue:@"Connected."];
}

- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection
{
  NSLog(@"Disconnected!");
  [self.connectionStatus setStringValue:@"Disconnected."];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
  NSLog(@"Connection Failed! %@", error);
  [self.connectionStatus setStringValue:[NSString stringWithFormat:@"Connection Failed (%@)", [error localizedDescription]]];
}

@end
