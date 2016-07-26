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

@end

#endif /* PTNativePusher_h */
