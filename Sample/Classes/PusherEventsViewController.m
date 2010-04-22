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
#import "NewEventViewController.h"

@implementation PusherEventsViewController

@synthesize eventsPusher;
@synthesize eventsReceived;

- (void)viewDidLoad 
{
  self.tableView.rowHeight = 55;
  
  if (eventsReceived == nil) {
    eventsReceived = [[NSMutableArray alloc] init];
  }
  if (eventsPusher == nil) {
    eventsPusher = [[PTPusher alloc] initWithKey:PUSHER_API_KEY channel:@"events"];
    [eventsPusher addEventListener:@"new-event" target:self selector:@selector(handleNewEvent:)];
  }
  
  UIBarButtonItem *newEventButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentNewEventScreen)];
  self.toolbarItems = [NSArray arrayWithObject:newEventButtonItem];
  
  [super viewDidLoad];
}

- (void)dealloc {
  [eventsReceived release];
  [eventsPusher release];
  [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)presentNewEventScreen;
{
  NewEventViewController *newEventController = [[NewEventViewController alloc] init];
  newEventController.delegate = self;
  [self presentModalViewController:newEventController animated:YES];
  [newEventController release];
}

- (void)sendEventWithMessage:(NSString *)message;
{
  NSLog(@"Got message: %@", message);
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark PTPusherEvent handling

- (void)handleNewEvent:(PTPusherEvent *)event;
{
  [self.tableView beginUpdates];
  [eventsReceived insertObject:event atIndex:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
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
