//
//  PusherPresenceViewController.m
//  libPusher
//
//  Created by Juan Alvarez on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PusherPresenceViewController.h"

#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "Constants.h"

@implementation PusherPresenceViewController

@synthesize members;
@synthesize pusher, presenceChannel;

+ (PusherPresenceViewController *)controller
{
	PusherPresenceViewController *cont = [[[PusherPresenceViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
	cont.title = @"Presence";

	return cont;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight = 55;
	
	if (members == nil) members = [[NSMutableArray alloc] init];
	
	self.presenceChannel = [self.pusher subscribeToChannel:@"presence-my-channel" 
											 withAuthPoint:[NSURL URLWithString:PRESENCE_AUTH_URL]
												  delegate:self];
	
	[presenceChannel addSubscriptionSucceededEventListener:^(NSArray *userList) {
		NSLog(@"\nMember List:\n%@", [userList description]);
		
		[self.tableView beginUpdates];
		
		for (NSDictionary *userDict in userList) {
			if ([members indexOfObject:userDict] == NSNotFound) {
				[members addObject:userDict];
				
				NSInteger index = [members indexOfObject:userDict];
				NSArray *indexes = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
				
				[self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
			}
		}
		
		[self.tableView endUpdates];
	}];
	
	[presenceChannel addMemberAddedEventListener:^(NSDictionary *userInfo) {
		NSLog(@"\nMember Added:\n%@", [userInfo description]);

		if ([members indexOfObject:userInfo] == NSNotFound) {
			[self.tableView beginUpdates];
			[members insertObject:userInfo atIndex:0];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
			[self.tableView endUpdates];
		}
	}];
	
	[presenceChannel addMemberRemovedEventListener:^(NSDictionary *userInfo) {
		NSLog(@"\nMember Removed:\n%@", [userInfo description]);

		NSInteger index = [members indexOfObject:userInfo];
		
		if (index != NSNotFound) {
			[self.tableView beginUpdates];
			[members removeObjectAtIndex:index];
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
			[self.tableView endUpdates];
		}
	}];
}

#pragma mark -
#pragma mark PTPusherChannel Delegate

- (NSDictionary *)extraParamsForChannelAuthentication:(PTPusherChannel *)channel
{
	NSString *deviceName = [[UIDevice currentDevice] name];
	
	NSLog(deviceName, nil);
	
	if ([deviceName isEqualToString:@"Juan's iPhone 4"]) {
		return [NSDictionary dictionaryWithObject:@"1" forKey:@"user_id"];
	}
	
	return [NSDictionary dictionaryWithObject:@"2" forKey:@"user_id"];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.members count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *memberDict = [members objectAtIndex:indexPath.row];
	NSDictionary *memberInfo = [memberDict objectForKey:@"user_info"];
	
	cell.textLabel.text = [memberInfo objectForKey:@"name"];
	cell.detailTextLabel.text = [memberInfo objectForKey:@"email"];
    
    return cell;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[members release];
	[pusher release];
	[presenceChannel release];
	
    [super dealloc];
}


@end

