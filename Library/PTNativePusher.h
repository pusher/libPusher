//
//  PTNativePusher.h
//  libPusher
//
//  Created by James Fisher on 25/07/2016.
//
//

#ifndef PTNativePusher_h
#define PTNativePusher_h

#import "PTPusherDelegate.h"

@interface PTNativePusher : NSObject

/** The object that acts as the delegate for the receiving instance.
 
 The delegate must implement the PTPusherDelegate protocol. The delegate is not retained.
 */
@property (nonatomic, weak) id<PTPusherDelegate> delegate;

// Takes ownership of the pusherAppKey string
- (id)initWithPusherAppKey:(NSString *)pusherAppKey delegate:(id<PTPusherDelegate>)delegate;

- (void) registerWithDeviceToken: (NSData *) deviceToken;

- (void) subscribe:(NSString *)interestName;

- (void) unsubscribe:(NSString *)interestName;

@end

#endif /* PTNativePusher_h */
