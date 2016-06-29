//
//  SpecHelper.m
//  libPusher
//
//  Created by Luke Redpath on 13/12/2011.
//  Copyright (c) 2011 LJR Software Limited. All rights reserved.
//

#import "SpecHelper.h"
#import "Constants.h"
#import "PTPusherAPI.h"
#import "PTPusherMockConnection.h"
#import "PTPusherChannelServerBasedAuthorization.h"

PTPusher *newTestClient(void) {
  PTPusher *client = newTestClientDisconnected();
  [client connect];
  return client;
}

PTPusher *newTestClientWithMockConnection(void)
{
  PTPusherMockConnection *mockConnection = [[PTPusherMockConnection alloc] init];
  PTPusher *client = [[PTPusher alloc] initWithConnection:mockConnection];
  client.delegate = [PTPusherClientTestHelperDelegate sharedInstance];
  return client;
}

PTPusher *newTestClientDisconnected(void) {
  NSDictionary *environment = [[NSProcessInfo processInfo] environment];
  NSString *appKey = environment[@"PUSHER_API_KEY"];

  if (!appKey) {
    NSCAssert(![PUSHER_API_KEY isEqualToString:@""], @"You must supply a Pusher app key");
    appKey = PUSHER_API_KEY;
  }

  PTPusher *client = [PTPusher pusherWithKey:appKey delegate:[PTPusherClientTestHelperDelegate sharedInstance] encrypted:NO];
  return client;
}

void enableClientDebugging(void)
{
  [[PTPusherClientTestHelperDelegate sharedInstance] setDebugEnabled:YES];
}

void sendTestEvent(NSString *eventName)
{
  sendTestEventOnChannel(@"test-channel", eventName);
}

void sendTestEventOnChannel(NSString *channelName, NSString *eventName)
{
  NSDictionary *environment = [[NSProcessInfo processInfo] environment];
  NSString *appId = environment[@"PUSHER_APP_ID"];
  NSString *appKey = environment[@"PUSHER_APP_KEY"];
  NSString *appSecret = environment[@"PUSHER_API_SECRET"];

  if (!appId) {
    NSCAssert(![PUSHER_APP_ID isEqualToString:@""], @"You must supply a Pusher app ID");
    appId = PUSHER_APP_ID;
  }
  if (!appKey) {
    NSCAssert(![PUSHER_API_KEY isEqualToString:@""], @"You must supply a Pusher app key");
    appKey = PUSHER_API_KEY;
  }
  if (!appSecret) {
    NSCAssert(![PUSHER_API_SECRET isEqualToString:@""], @"You must supply a Pusher app secret");
    appSecret = PUSHER_API_SECRET;
  }

  __strong static PTPusherAPI *_sharedAPI = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedAPI = [[PTPusherAPI alloc] initWithKey:appKey appID:appId secretKey:appSecret];
  });

  [_sharedAPI triggerEvent:eventName onChannel:channelName data:[NSArray arrayWithObject:@"dummy data"] socketID:@"99999.99999"];
}

void onConnect(dispatch_block_t block)
{
  [[PTPusherClientTestHelperDelegate sharedInstance] onConnect:block];
}

void onDisconnect(dispatch_block_t block)
{
  [[PTPusherClientTestHelperDelegate sharedInstance] onDisconnect:block];
}

void onAuthorizationRequired(void (^authBlock)(NSMutableURLRequest *))
{
  [[PTPusherClientTestHelperDelegate sharedInstance] onAuthorizationRequired:authBlock];
}

void onFailedToSubscribe(void (^failedToSubscribeBlock)(PTPusherChannel *))
{
  [[PTPusherClientTestHelperDelegate sharedInstance] onFailedToSubscribe:failedToSubscribeBlock];
}

void onSubscribe(void (^subscribeBlock)(PTPusherChannel *))
{
  [[PTPusherClientTestHelperDelegate sharedInstance] onSubscribe:subscribeBlock];
}

void waitForClientToDisconnect(PTPusher *client)
{
  if (![[PTPusherClientTestHelperDelegate sharedInstance] connected]) return;

  while ([[PTPusherClientTestHelperDelegate sharedInstance] connected]) {
    NSLog(@"Waiting for client to disconnect...");
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
}

@implementation PTPusherEventMatcher

+ (NSArray *)matcherStrings {
  return [NSArray arrayWithObjects:@"beEventNamed:", nil];
}

- (void)beEventNamed:(NSString *)name
{
  expectedEventName = [name copy];
}

- (BOOL)evaluate
{
  PTPusherEvent *event = self.subject;
  return [event.name isEqualToString:expectedEventName];
}

- (NSString *)failureMessageForShould
{
  return [NSString stringWithFormat:@"expected event named %@, got %@", expectedEventName, self.subject];
}

@end

@implementation PTPusherClientTestHelperDelegate

@synthesize connected;
@synthesize debugEnabled;

+ (id)sharedInstance
{
  static dispatch_once_t pred = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&pred, ^{
    _sharedObject = [[self alloc] init];
  });
  return _sharedObject;
}

- (void)onConnect:(dispatch_block_t)block
{
  if (connected) {
    block();
  }
  else {
    connectedBlock = [block copy];
  }
}

- (void)onDisconnect:(dispatch_block_t)block
{
  disconnectedBlock = [block copy];
}

- (void)onAuthorizationRequired:(void (^)(NSMutableURLRequest *))authBlock
{
  onAuthorizationBlock = [authBlock copy];
}

- (void)onFailedToSubscribe:(void (^)(PTPusherChannel *))failedToSubscribeBlock
{
  onFailedToSubscribeBlock = [failedToSubscribeBlock copy];
}

- (void)onSubscribe:(void (^)(PTPusherChannel *))subscribeBlock
{
  onSubscribeBlock = [subscribeBlock copy];
}

#pragma mark - Delegate methods

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
  if (self.debugEnabled) {
    NSLog(@"[DEBUG] Client connected");
  }
  if (connectedBlock) {
    connectedBlock();
    connectedBlock = nil;
  }
  connected = YES;
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
  if (self.debugEnabled) {
    NSLog(@"[DEBUG] Client disconnected");
  }
  if (disconnectedBlock) {
    disconnectedBlock();
    disconnectedBlock = nil;
  }
  connected = NO;
  connectedBlock = nil;
  onAuthorizationBlock = nil;
  onSubscribeBlock = nil;
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
  if (self.debugEnabled) {
     NSLog(@"[DEBUG] Client connection failed with error %@", error);
  }
  connected = NO;
  connectedBlock = nil;
  onAuthorizationBlock = nil;
  onSubscribeBlock = nil;
}

- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withAuthOperation:(PTPusherChannelAuthorizationOperation *)operation
{
  if (onAuthorizationBlock) {
    onAuthorizationBlock(operation.mutableURLRequest);
  }
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
  if (onFailedToSubscribeBlock) {
    onFailedToSubscribeBlock(channel);
  }
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
  if (onSubscribeBlock) {
    onSubscribeBlock(channel);
  }
}

@end

@implementation PTPusherNotificationHandler

+ (id)sharedInstance
{
  static dispatch_once_t pred = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&pred, ^{
    _sharedObject = [[self alloc] init];
  });
  return _sharedObject;
}

- (id)init {
  if ((self = [super init])) {
    observers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)addObserverForNotificationName:(NSString *)notificationName object:(id)object 
                    notificationCentre:(NSNotificationCenter *)notificationCenter 
                             withBlock:(void (^)(NSNotification *))block
{
  [observers setObject:[block copy] forKey:notificationName];
  [notificationCenter addObserver:self selector:@selector(handleNotification:) name:notificationName object:object];
}

- (void)handleNotification:(NSNotification *)note
{
  void (^block)(NSNotification *) = [observers objectForKey:note.name];
  
  if (block) {
    block(note);
  }
}

@end

@implementation NSNotificationCenter (BlockHandler)

- (void)addObserver:(NSString *)noteName object:(id)object usingBlock:(void (^)(NSNotification *))block
{
  [[PTPusherNotificationHandler sharedInstance] addObserverForNotificationName:noteName object:object notificationCentre:self withBlock:block];
}

@end


