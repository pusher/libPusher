//
//  LRAppDelegate.h
//  PusherSampleOSX
//
//  Created by Luke Redpath on 05/02/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LRAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *eventsTableView;
@property (nonatomic, strong) NSMutableArray *events;
@property (weak) IBOutlet NSArrayController *eventsController;


@end
