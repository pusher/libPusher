//
//  LRAppDelegate.m
//  PusherSampleOSX
//
//  Created by Luke Redpath on 05/02/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "LRAppDelegate.h"
#import <libPusher/PTPusherEvent.h>

@implementation LRAppDelegate

@synthesize window = _window;
@synthesize eventsTableView = _eventsTableView;
@synthesize events = _events;
@synthesize eventsController = _eventsController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  _events = [[NSMutableArray alloc] init];
}

@end
