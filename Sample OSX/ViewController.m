//
//  ViewController.m
//  SampleAppOSX
//
//  Created by Hamilton Chapman on 12/07/2016.
//
//

#import "ViewController.h"
#import "Constants.h"
#import <Pusher/PTPusher.h>
#import <Pusher/PTPusherChannel.h>
#import <Pusher/PTPusherEvent.h>

@implementation ViewController

@synthesize window = _window;
@synthesize eventsTableView = _eventsTableView;
@synthesize events = _events;
@synthesize eventsController = _eventsController;
@synthesize connectionStatus = _connectionStatus;
@synthesize pusher;

- (void)viewDidLoad {
    [super viewDidLoad];
    _events = [[NSMutableArray alloc] init];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)connectToPusher:(id)sender {
    [sender setEnabled:NO];

    self.pusher = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:YES];
    [self.pusher connect];

    PTPusherChannel *channel = [self.pusher subscribeToChannelNamed:@"messages"];

    [[NSNotificationCenter defaultCenter] addObserverForName:PTPusherEventReceivedNotification object:channel queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {

      NSLog(@"Received message: %@", note);

      [self.eventsController addObject:[note.userInfo objectForKey:PTPusherEventUserInfoKey]];
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

- (CGFloat)tableView:(NSTableView *)aTableView heightOfRow:(NSInteger)row {
    CGFloat heightOfRow = 100;
    return heightOfRow;
}

@end
