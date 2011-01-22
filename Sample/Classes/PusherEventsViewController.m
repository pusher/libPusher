//
//  PusherEventsViewController.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherEventsViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "NewEventViewController.h"

@implementation PusherEventsViewController

@synthesize eventsChannel;
@synthesize eventsReceived;

- (void)viewDidLoad 
{
	self.tableView.rowHeight = 55;
	
	UIBarButtonItem *newEventButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentNewEventScreen)];
	self.toolbarItems = [NSArray arrayWithObject:newEventButtonItem];
	[newEventButtonItem release];

	if (eventsReceived == nil) eventsReceived = [[NSMutableArray alloc] init];
	
	[eventsChannel addEventListener:@"new-event" block:^(PTPusherEvent *event) {
		[self.tableView beginUpdates];
		[eventsReceived insertObject:event atIndex:0];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
		[self.tableView endUpdates];
	}];

	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)dealloc {
	[eventsChannel release];
	[eventsReceived release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)presentNewEventScreen;
{
	NewEventViewController *newEventController = [[[NewEventViewController alloc] init] autorelease];
	newEventController.delegate = self;
	
	[self presentModalViewController:newEventController animated:YES];
}

- (void)sendEventWithMessage:(NSString *)message;
{
	NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:message, @"title", @"Sent from libPusher", @"description", nil];

	[self performSelector:@selector(sendEvent:) withObject:payload afterDelay:0.3];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)sendEvent:(id)payload;
{
	[self.eventsChannel triggerEvent:@"new-event" data:payload];
}

#pragma mark -
#pragma mark PTPusherChannel delegate

- (void)channelFailedToTriggerEvent:(PTPusherChannel *)channel error:(NSError *)error
{
  NSLog(@"Error triggering event on channel %@, error: %@", channel.name, error);
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	return eventsReceived.count;
}

static NSString *EventCellIdentifier = @"EventCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EventCellIdentifier] autorelease];
	}
	
	PTPusherEvent *event = [eventsReceived objectAtIndex:indexPath.row];
	cell.textLabel.text = [event.data valueForKey:@"title"];
	cell.detailTextLabel.text = [event.data valueForKey:@"description"];

	return cell;
}

@end
