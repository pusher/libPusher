//
//  NewEventViewController.h
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PusherEventsViewController.h"

@interface NewEventViewController : UIViewController {
  UITextView *textView;
  id<PusherEventsDelegate> __unsafe_unretained delegate;
}
@property (nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, unsafe_unretained) id<PusherEventsDelegate> delegate;

- (IBAction)sendEvent:(id)sender;
- (IBAction)cancel:(id)sender;
@end
