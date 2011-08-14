//
//  PusherEventsViewController.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherPresenceEventsViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "PTPusherAPI.h"
#import "PTPusherConnection.h"
#import "NewEventViewController.h"


@implementation PusherPresenceEventsViewController

@synthesize pusher;
@synthesize currentChannel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    connectedClients = [[NSMutableArray alloc] init];
    memberIDs = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  self.title = @"Presence";
  self.tableView.rowHeight = 55;

  UIBarButtonItem *newClientButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Client" style:UIBarButtonItemStyleBordered target:self action:@selector(connectClient)];
  self.toolbarItems = [NSArray arrayWithObject:newClientButtonItem];
  [newClientButtonItem release];
  
  // configure the auth URL for private/presence channels
  self.pusher.authorizationURL = [NSURL URLWithString:@"http://localhost:9292/presence/auth"];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self subscribeToPresenceChannel:@"demo"];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  // unsubscribe before we go back to the main menu
  [self.pusher unsubscribeFromChannel:self.currentChannel]; 
}

- (void)dealloc 
{
  [memberIDs release];
  [connectedClients release];
  [pusher release];
  [currentChannel release];
  [super dealloc];
}

#pragma mark - Subscribing

- (void)subscribeToPresenceChannel:(NSString *)channelName
{
  self.currentChannel = [self.pusher subscribeToPresenceChannelNamed:channelName delegate:self];
}

#pragma mark - Actions

- (void)connectClient
{
  PTPusher *client = [PTPusher pusherWithKey:PUSHER_API_KEY connectAutomatically:YES];
  client.authorizationURL = pusher.authorizationURL;
  [connectedClients addObject:client];
  [client subscribeToPresenceChannelNamed:@"demo"];
}

- (void)disconnectLastClient
{
  PTPusher *client = [connectedClients lastObject];
  [client disconnect];
  [connectedClients removeObject:client];
}

#pragma mark - Presence channel events

- (void)presenceChannel:(PTPusherPresenceChannel *)channel didSubscribeWithMemberList:(NSArray *)members
{
  [memberIDs addObjectsFromArray:[members valueForKey:@"user_id"]];
  [self.tableView reloadData];
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAdded:(NSDictionary *)memberData
{
  [self.tableView beginUpdates];
  [memberIDs insertObject:[memberData objectForKey:@"user_id"] atIndex:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                        withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemoved:(NSDictionary *)memberData
{
  NSString *memberID = [memberData objectForKey:@"user_id"];
  NSInteger indexOfMember = [memberIDs indexOfObject:memberID];
  
  [self.tableView beginUpdates];
  [memberIDs removeObject:memberID];
  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexOfMember inSection:0]] 
                        withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
  return memberIDs.count;
}

static NSString *EventCellIdentifier = @"EventCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EventCellIdentifier] autorelease];
  }
  NSString *memberID = [memberIDs objectAtIndex:indexPath.row];
  NSDictionary *memberData = [self.currentChannel.members objectForKey:memberID];

  cell.textLabel.text = [NSString stringWithFormat:@"Member: %@", memberID];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"Name: %@ Email: %@", [memberData objectForKey:@"name"], [memberData objectForKey:@"email"]];
  
  return cell;
}

@end
