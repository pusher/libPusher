//
//  ReactiveEventsViewController.m
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import "ReactiveEventsViewController.h"
#import "PTPusherAPI.h"
#import "Constants.h"
#import "Pusher.h"
#import "PTPusherChannel+ReactiveExtensions.h"

#define UIColorFromRGBHexValue(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ReactiveEventsViewController ()
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, strong) PTPusherAPI *api;
@end

@implementation ReactiveEventsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.api = [[PTPusherAPI alloc] initWithKey:PUSHER_API_KEY appID:PUSHER_APP_ID secretKey:PUSHER_API_SECRET];
  
  // subscribe to the channel
  PTPusherChannel *colorChannel = [self.pusher subscribeToChannelNamed:@"colors"];
  
  // Create a signal by mapping a channel events to a UIColor, converting the color string then a UIColor value
  RACSignal *colorSignal = [[colorChannel eventsOfType:@"color"] map:^id(PTPusherEvent *event) {
    NSScanner *scanner = [NSScanner scannerWithString:event.data[@"color"]];
    unsigned long long hexValue;
    [scanner scanHexLongLong:&hexValue];
    return UIColorFromRGBHexValue(hexValue);
  }];
  
  // Bind the view's background color to colors as the arrivecol
  RAC(self.view, backgroundColor) = colorSignal;
  
  
  // log all events received on the channel using the allEvents signal
  [[[colorChannel allEvents] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(PTPusherEvent *event) {
    NSLog(@"[pusher] Received color event %@", event);
  }];
}

- (IBAction)tappedSendButton:(id)sender
{
  // we set the socket ID to nil here as we want to receive our own events
  [self.api triggerEvent:@"color" onChannel:@"colors" data:@{@"color": self.textField.text} socketID:nil];
}

@end
