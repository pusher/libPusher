//
//  ViewController.h
//  SampleAppOSX
//
//  Created by Hamilton Chapman on 12/07/2016.
//
//

#import <Cocoa/Cocoa.h>
#import <Pusher/PTPusherDelegate.h>

@class PTPusher;

@interface ViewController : NSViewController <PTPusherDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *connectionStatus;
@property (weak) IBOutlet NSTableView *eventsTableView;
@property (strong) IBOutlet NSArrayController *eventsController;

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) PTPusher *pusher;

@end

