//
//  LRAppDelegate.h
//  PusherSampleOSX
//
//  Created by Luke Redpath on 05/02/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Pusher/PTPusherDelegate.h>

@class PTPusher;

@interface LRAppDelegate : NSObject <NSApplicationDelegate, PTPusherDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *eventsTableView;
@property (weak) IBOutlet NSArrayController *eventsController;
@property (weak) IBOutlet NSTextField *connectionStatus;

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) PTPusher *pusher;

@end
