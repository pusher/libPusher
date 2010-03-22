//
//  PTWebSocket.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  PTWebSocketConnecting = 0,
  PTWebSocketOpen,
  PTWebSocketClosing,
  PTWebSocketClosed
} PTWebSocketReadyState;

@interface PTWebSocket : NSObject {
  NSURL *URL;
  NSString *protocol;
  PTWebSocketReadyState readyState;
}
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) PTWebSocketReadyState readyState;

- (id)initWithURL:(NSURL *)_URL;
- (id)initWithURL:(NSURL *)_URL protocol:(NSString *)_protocol;

- (void)send:(NSString *)data;
- (void)close;
@end
