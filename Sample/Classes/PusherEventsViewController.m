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

@synthesize pusher;
@synthesize currentChannel;
@synthesize eventsReceived;

- (void)awakeFromNib
{
  eventsReceived = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  self.tableView.rowHeight = 55;

  UIBarButtonItem *newEventButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentNewEventScreen)];
  self.toolbarItems = [NSArray arrayWithObject:newEventButtonItem];
  [newEventButtonItem release];
  
  [self.pusher onConnectionEstablished:^{
    [self subscribeToChannel:@"messages"];
  }];
}

- (void)dealloc 
{
  [currentChannel release];
  [eventsReceived release];
  [super dealloc];
}

#pragma mark - Subscribing

- (void)subscribeToChannel:(NSString *)channelName
{
  self.currentChannel = [self.pusher subscribeToChannelNamed:channelName];
  [self.currentChannel bindToEventNamed:@"new-message" target:self action:@selector(receivedMessageEvent:)];
}

#pragma mark - Actions

- (void)presentNewEventScreen;
{
  NewEventViewController *newEventController = [[NewEventViewController alloc] init];
  newEventController.delegate = self;
  [self presentModalViewController:newEventController animated:YES];
  [newEventController release];
}

- (void)sendEventWithMessage:(NSString *)message;
{
  // construct a simple payload for the event
  NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", nil];

  // send the event after a short delay, wait for modal view to disappear
  [self performSelector:@selector(sendEvent:) withObject:payload afterDelay:0.3];
  [self dismissModalViewControllerAnimated:YES];
}

- (void)sendEvent:(id)payload;
{
  [self.currentChannel triggerEventNamed:@"new-message" data:payload];
}

#pragma mark - Event handling

- (void)receivedMessageEvent:(PTPusherEvent *)event;
{
  [self.tableView beginUpdates];
  [eventsReceived insertObject:event atIndex:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource methods

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

  cell.textLabel.text = event.name;
  cell.detailTextLabel.text = [event.data description];
  
  return cell;
}

@end
