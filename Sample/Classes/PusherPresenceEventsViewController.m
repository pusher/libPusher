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
#import "NSMutableURLRequest+BasicAuth.h"
#import "Constants.h"
#import "PusherEventsAppDelegate.h"

@interface PusherPresenceEventsViewController ()
@property (nonatomic, strong) UIBarButtonItem *joinButtonItem;
@property (nonatomic, strong) UIBarButtonItem *leaveButtonItem;
@property (nonatomic, strong) NSMutableArray *members;
@end

@implementation PusherPresenceEventsViewController

@synthesize pusher = _pusher;
@synthesize currentChannel;

- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  self.title = @"Presence";
  self.tableView.rowHeight = 55;
  self.members = [NSMutableArray array];

  self.joinButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Join"
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(joinChannel:)];
  
  self.leaveButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Leave"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(leaveChannel:)];
  
  self.navigationItem.rightBarButtonItem = self.joinButtonItem;
  
  // configure the auth URL for private/presence channels
  self.pusher.authorizationURL = [NSURL URLWithString:@"http://localhost:9292/presence/auth"];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  if ([self.currentChannel isSubscribed]) {
    [self.currentChannel unsubscribe];
  }
}

- (void)joinChannel:(id)sender
{
  [self subscribeToPresenceChannel:@"demo"];
}

- (void)leaveChannel:(id)sender
{
  [self.currentChannel unsubscribe];
  self.currentChannel = nil;
  
  self.navigationItem.rightBarButtonItem = self.joinButtonItem;

  [self.members removeAllObjects];
  [self.tableView reloadData];
}

#pragma mark - Subscribing

- (void)subscribeToPresenceChannel:(NSString *)channelName
{
  self.currentChannel = [self.pusher subscribeToPresenceChannelNamed:channelName delegate:self];
}

#pragma mark - Presence channel events

- (void)presenceChannelDidSubscribe:(PTPusherPresenceChannel *)channel
{
  NSLog(@"[pusher] Channel members: %@", channel.members);

  self.navigationItem.rightBarButtonItem = self.leaveButtonItem;

  [channel.members enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
    [self.members addObject:obj];
  }];
  
  [self.tableView reloadData];
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAdded:(PTPusherChannelMember *)member
{
  NSLog(@"[pusher] Member joined channel: %@", member);
  
  [self.members addObject:member];
  
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.members.count-1 inSection:0]]
                        withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemoved:(PTPusherChannelMember *)member
{
  NSLog(@"[pusher] Member left channel: %@", member);
  
  NSInteger memberIndex = [self.members indexOfObject:member];
  [self.members removeObject:member];

  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:memberIndex inSection:0]]
                        withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
  return self.currentChannel.members.count;
}

static NSString *EventCellIdentifier = @"EventCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:EventCellIdentifier];
  }
  PTPusherChannelMember *member = self.members[indexPath.row];

  cell.textLabel.text = [NSString stringWithFormat:@"Member: %@", member.userID];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"Name: %@ Email: %@", member.userInfo[@"name"], member.userInfo[@"email"]];
  
  return cell;
}

@end
