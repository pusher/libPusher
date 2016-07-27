//
//  PTNativePusher.h
//  libPusher
//
//  Created by James Fisher on 25/07/2016.
//
//

#ifndef PTNativePusher_h
#define PTNativePusher_h

@interface PTNativePusher : NSObject

// Takes ownership of the pusherAppKey string
- (id)initWithPusherAppKey:(NSString *)pusherAppKey;

- (void) registerWithDeviceToken: (NSData*) deviceToken;

- (void) subscribe:(NSString *)interestName;

- (void) unsubscribe:(NSString *)interestName;

@end

#endif /* PTNativePusher_h */
