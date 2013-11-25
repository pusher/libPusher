//
//  PTPusherClient.m
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusherChannel.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherEventDispatcher.h"
#import "PTTargetActionEventListener.h"
#import "PTBlockEventListener.h"
#import "PTPusherChannelAuthorizationOperation.h"
#import "PTPusherErrors.h"
#import "PTJSON.h"

@interface PTPusher ()
- (void)__unsubscribeFromChannel:(PTPusherChannel *)channel;
- (void)beginAuthorizationOperation:(PTPusherChannelAuthorizationOperation *)operation;
@end

@interface PTPusherChannel () 
@property (nonatomic, assign, readwrite) BOOL subscribed;
@end

#pragma mark -

@implementation PTPusherChannel

@synthesize name;
@synthesize subscribed;

+ (id)channelWithName:(NSString *)name pusher:(PTPusher *)pusher
{
  if ([name hasPrefix:@"private-"]) {
    return [[PTPusherPrivateChannel alloc] initWithName:name pusher:pusher];
  }
  if ([name hasPrefix:@"presence-"]) {
    return [[PTPusherPresenceChannel alloc] initWithName:name pusher:pusher];
  }
  return [[self alloc] initWithName:name pusher:pusher];
}

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)aPusher
{
  if (self = [super init]) {
    name = [channelName copy];
    pusher = aPusher;
    dispatcher = [[PTPusherEventDispatcher alloc] init];
    internalBindings = [[NSMutableArray alloc] init];
    
    /*
     Set up event handlers for pre-defined channel events
     
     We *must* use block-based bindings with a weak reference to the channel.
     Using a target-action binding will create a retain cycle between the channel
     and the target/action binding object.
     */
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
    __weak PTPusherChannel *weakChannel = self;
#else
    __unsafe_unretained PTPusherChannel *weakChannel = self;
#endif
    
    [internalBindings addObject:
     [self bindToEventNamed:@"pusher_internal:subscription_succeeded" 
            handleWithBlock:^(PTPusherEvent *event) {
              [weakChannel handleSubscribeEvent:event];
            }]];
    
    [internalBindings addObject:
     [self bindToEventNamed:@"subscription_error" 
            handleWithBlock:^(PTPusherEvent *event) {
              [weakChannel handleSubcribeErrorEvent:event];
            }]];
  }
  return self;
}

- (void)dealloc 
{
  [internalBindings enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
    [dispatcher removeBinding:object];
  }];
}

- (BOOL)isPrivate
{
  return NO;
}

- (BOOL)isPresence
{
  return NO;
}

#pragma mark - Subscription events

- (void)handleSubscribeEvent:(PTPusherEvent *)event
{
  self.subscribed = YES;
  
  if ([pusher.delegate respondsToSelector:@selector(pusher:didSubscribeToChannel:)]) {
    [pusher.delegate pusher:pusher didSubscribeToChannel:self];
  }
}

- (void)handleSubcribeErrorEvent:(PTPusherEvent *)event
{
  if ([pusher.delegate respondsToSelector:@selector(pusher:didFailToSubscribeToChannel:withError:)]) {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:event forKey:PTPusherErrorUnderlyingEventKey];
    NSError *error = [NSError errorWithDomain:PTPusherErrorDomain code:PTPusherSubscriptionError userInfo:userInfo];
    [pusher.delegate pusher:pusher didFailToSubscribeToChannel:self withError:error];
  }
}

#pragma mark - Authorization

- (void)authorizeWithCompletionHandler:(void(^)(BOOL, NSDictionary *, NSError *))completionHandler
{
  completionHandler(YES, [NSDictionary dictionary], nil); // public channels do not require authorization
}

#pragma mark - Binding to events

- (PTPusherEventBinding *)bindToEventNamed:(NSString *)eventName target:(id)target action:(SEL)selector
{
  return [dispatcher addEventListenerForEventNamed:eventName target:target action:selector];
}

- (PTPusherEventBinding *)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block
{
  return [self bindToEventNamed:eventName handleWithBlock:block queue:dispatch_get_main_queue()];
}

- (PTPusherEventBinding *)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block queue:(dispatch_queue_t)queue
{
  return [dispatcher addEventListenerForEventNamed:eventName block:block queue:queue];
}

- (void)removeBinding:(PTPusherEventBinding *)binding
{
  [dispatcher removeBinding:binding];
}

- (void)removeAllBindings
{
  NSMutableArray *bindingsToRemove = [NSMutableArray array];
  
  // need to unpack the bindings from the nested arrays, so we can
  // iterate over them safely whilst removing them from the dispatcher
  for (NSArray *bindingsArray in [dispatcher.bindings allValues]) {
    for (PTPusherEventBinding *binding in bindingsArray) {
	    if (![internalBindings containsObject:binding]) {
        [bindingsToRemove addObject:binding];
      }
	  }
  }
  
  for (PTPusherEventBinding *binding in bindingsToRemove) {
    [dispatcher removeBinding:binding];
  }
}

#pragma mark - Dispatching events

- (void)dispatchEvent:(PTPusherEvent *)event
{
  [dispatcher dispatchEvent:event];
  
  [[NSNotificationCenter defaultCenter] 
   postNotificationName:PTPusherEventReceivedNotification 
   object:self 
   userInfo:[NSDictionary dictionaryWithObject:event forKey:PTPusherEventUserInfoKey]];
}

#pragma mark - Internal use only

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  if (self.isSubscribed) return;
  
  [pusher sendEventNamed:@"pusher:subscribe" 
                    data:[NSDictionary dictionaryWithObject:self.name forKey:@"channel"]
                 channel:nil];
}

- (void)unsubscribe
{
  [pusher __unsubscribeFromChannel:self];
}

- (void)handleDisconnect
{
  self.subscribed = NO;
}

@end

#pragma mark -

@implementation PTPusherPrivateChannel {
  NSOperationQueue *clientEventQueue;
}

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)aPusher
{
  if ((self = [super initWithName:channelName pusher:aPusher])) {
    clientEventQueue = [[NSOperationQueue alloc] init];
    clientEventQueue.maxConcurrentOperationCount = 1;
    clientEventQueue.name = @"com.pusher.libPusher.clientEventQueue";
    clientEventQueue.suspended = YES;
  }
  return self;
}

- (void)handleSubscribeEvent:(PTPusherEvent *)event
{
  [super handleSubscribeEvent:event];
  [clientEventQueue setSuspended:NO];
}

- (void)handleDisconnect
{
  [super handleDisconnect];
  [clientEventQueue setSuspended:YES];
}

- (BOOL)isPrivate
{
  return YES;
}

- (void)authorizeWithCompletionHandler:(void(^)(BOOL, NSDictionary *, NSError *))completionHandler
{
  PTPusherChannelAuthorizationOperation *authOperation = [PTPusherChannelAuthorizationOperation operationWithAuthorizationURL:pusher.authorizationURL channelName:self.name socketID:pusher.connection.socketID];
  
  [authOperation setCompletionHandler:^(PTPusherChannelAuthorizationOperation *operation) {
    completionHandler(operation.isAuthorized, operation.authorizationData, operation.error);
  }];
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  NSLog(@"willAuthorizeChannelWithRequest: is deprecated and will be removed in 1.6. Use pusher:willAuthorizeChannel:withRequest: instead.");
  if ([pusher.delegate respondsToSelector:@selector(pusher:willAuthorizeChannelWithRequest:)]) { // deprecated call
    [pusher.delegate pusher:pusher willAuthorizeChannelWithRequest:authOperation.mutableURLRequest];
  }
#pragma clang diagnostic pop
    
  if ([pusher.delegate respondsToSelector:@selector(pusher:willAuthorizeChannel:withRequest:)]) {
    [pusher.delegate pusher:pusher willAuthorizeChannel:self withRequest:authOperation.mutableURLRequest];
  }
  
  [pusher beginAuthorizationOperation:authOperation];
}

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  if (self.isSubscribed) return;
  
  NSMutableDictionary *eventData = [authData mutableCopy];
  [eventData setObject:self.name forKey:@"channel"];
  
  [pusher sendEventNamed:@"pusher:subscribe" 
                    data:eventData
                 channel:nil];
}

#pragma mark - Triggering events

- (void)triggerEventNamed:(NSString *)eventName data:(id)eventData
{
  if (![eventName hasPrefix:@"client-"]) {
    eventName = [@"client-" stringByAppendingString:eventName];
  }
  
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
    __weak PTPusherChannel *weakSelf = self;
    __weak PTPusher *weakPusher = pusher;
#else
    __unsafe_unretained PTPusherChannel *weakSelf = self;
    __unsafe_unretained PTPusher *weakPusher = pusher;
#endif
  
  [clientEventQueue addOperationWithBlock:^{
    [weakPusher sendEventNamed:eventName data:eventData channel:weakSelf.name];
  }];
}

@end

#pragma mark -

@interface PTPusherChannelMembers ()

@property (nonatomic, copy, readwrite) NSString *myID;

- (void)reset;
- (void)handleSubscription:(NSDictionary *)subscriptionData;
- (PTPusherChannelMember *)handleMemberAdded:(NSDictionary *)memberData;
- (PTPusherChannelMember *)handleMemberRemoved:(NSDictionary *)memberData;

@end

@implementation PTPusherPresenceChannel

@synthesize presenceDelegate;
@synthesize members = _members;

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)aPusher
{
  if ((self = [super initWithName:channelName pusher:aPusher])) {
    _members = [[PTPusherChannelMembers alloc] init];

    /* Set up event handlers for pre-defined channel events.
     As above, use blocks as proxies to a weak channel reference to avoid retain cycles.
     */
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
      __weak PTPusherPresenceChannel *weakChannel = self;
#else
      __unsafe_unretained PTPusherPresenceChannel *weakChannel = self;
#endif
    
    [internalBindings addObject:
     [self bindToEventNamed:@"pusher_internal:member_added" 
            handleWithBlock:^(PTPusherEvent *event) {
              [weakChannel handleMemberAddedEvent:event];
            }]];
    
    [internalBindings addObject:
     [self bindToEventNamed:@"pusher_internal:member_removed" 
            handleWithBlock:^(PTPusherEvent *event) {
              [weakChannel handleMemberRemovedEvent:event];
            }]];
    
  }
  return self;
}

- (void)handleDisconnect
{
  [super handleDisconnect];
  [self.members reset];
}

- (void)subscribeWithAuthorization:(NSDictionary *)authData
{
  [super subscribeWithAuthorization:authData];
  
  NSDictionary *channelData = [[PTJSON JSONParser] objectFromJSONString:authData[@"channel_data"]];
  self.members.myID = channelData[@"user_id"];
}

- (void)handleSubscribeEvent:(PTPusherEvent *)event
{
  [super handleSubscribeEvent:event];
  
  [self.members handleSubscription:event.data];
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  if ([self.presenceDelegate respondsToSelector:@selector(presenceChannel:didSubscribeWithMemberList:)]) { // deprecated call
    NSLog(@"presenceChannel:didSubscribeWithMemberList: is deprecated and will be removed in 1.6. Use presenceChannelDidSubscribe: instead.");
    NSMutableArray *members = [NSMutableArray arrayWithCapacity:self.members.count];
    [self.members enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
      [members addObject:obj];
    }];
    [self.presenceDelegate presenceChannel:self didSubscribeWithMemberList:members];
  }
#pragma clang diagnostic pop

  [self.presenceDelegate presenceChannelDidSubscribe:self];
}

- (BOOL)isPresence
{
  return YES;
}

- (NSDictionary *)infoForMemberWithID:(NSString *)memberID
{
  return self.members[memberID];
}

- (NSArray *)memberIDs
{
  NSMutableArray *memberIDs = [NSMutableArray array];
  [self.members enumerateObjectsUsingBlock:^(PTPusherChannelMember *member, BOOL *stop) {
    [memberIDs addObject:member.userID];
  }];
  return memberIDs;
}

- (NSInteger)memberCount
{
  return self.members.count;
}

- (void)handleMemberAddedEvent:(PTPusherEvent *)event
{
  PTPusherChannelMember *member = [self.members handleMemberAdded:event.data];
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  if ([self.presenceDelegate respondsToSelector:@selector(presenceChannel:memberAddedWithID:memberInfo:)]) { // deprecated call
    NSLog(@"presenceChannel:memberAddedWithID:memberInfo: is deprecated and will be removed in 1.6. Use presenceChannel:memberAdded: instead.");
    [self.presenceDelegate presenceChannel:self memberAddedWithID:member.userID memberInfo:member.userInfo];
  }
#pragma clang diagnostic pop

  [self.presenceDelegate presenceChannel:self memberAdded:member];
}

- (void)handleMemberRemovedEvent:(PTPusherEvent *)event
{
  PTPusherChannelMember *member = [self.members handleMemberRemoved:event.data];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  if ([self.presenceDelegate respondsToSelector:@selector(presenceChannel:memberRemovedWithID:atIndex:)]) { // deprecated call
    NSLog(@"presenceChannel:memberRemovedWithID:atIndex: is deprecated and will be removed in 1.6. Use presenceChannel:memberRemoved: instead.");
    // we just send an index of -1 here: I don't want to jump through hoops to support a deprecated API call
    [self.presenceDelegate presenceChannel:self memberRemovedWithID:member.userID atIndex:-1];
  }
#pragma clang diagnostic pop
  
  [self.presenceDelegate presenceChannel:self memberRemoved:member];
}

@end

#pragma mark -

@implementation PTPusherChannelMember

- (id)initWithUserID:(NSString *)userID userInfo:(NSDictionary *)userInfo
{
  if ((self = [super init])) {
    _userID = [userID copy];
    _userInfo = [userInfo copy];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherChannelMember id:%@ info:%@>", self.userID, self.userInfo];
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
  return self.userInfo[key];
}

@end

@implementation PTPusherChannelMembers {
  NSMutableDictionary *_members;
}

- (id)init
{
  self = [super init];
  if (self) {
    _members = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)reset
{
  _members = [[NSMutableDictionary alloc] init];
  self.myID = nil;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<PTPusherChannelMembers members:%@>", _members];
}

- (NSInteger)count
{
  return _members.count;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
  return _members[key];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block
{
  [_members enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    block(obj, stop);
  }];
}


- (PTPusherChannelMember *)me
{
  return self[self.myID];
}

- (PTPusherChannelMember *)memberWithID:(NSString *)userID
{
  return self[userID];
}

#pragma mark - Channel event handling

- (void)handleSubscription:(NSDictionary *)subscriptionData
{
  NSDictionary *memberHash = subscriptionData[@"presence"][@"hash"];
  
  [memberHash enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSDictionary *userInfo, BOOL *stop) {
    PTPusherChannelMember *member = [[PTPusherChannelMember alloc] initWithUserID:userID userInfo:userInfo];
    _members[userID] = member;
  }];
}

- (PTPusherChannelMember *)handleMemberAdded:(NSDictionary *)memberData
{
  PTPusherChannelMember *member = [self memberWithID:memberData[@"user_id"]];
  if (member == nil) {
    member = [[PTPusherChannelMember alloc] initWithUserID:memberData[@"user_id"] userInfo:memberData[@"user_info"]];
    [_members setObject:member forKey:member.userID];
  }
  return member;
}

- (PTPusherChannelMember *)handleMemberRemoved:(NSDictionary *)memberData
{
  PTPusherChannelMember *member = [self memberWithID:memberData[@"user_id"]];
  if (member) {
    [_members removeObjectForKey:member.userID];
  }
  return member;
}

@end
