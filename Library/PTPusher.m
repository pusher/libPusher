//
//  PTPusher.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusher.h"
#import "PTEventListener.h"
#import "JSON.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"

NSString *const PTPusherEventReceivedNotification = @"PTPusherEventReceivedNotification";

#define kPTPusherReconnectDelay 5.0

@interface PTPusher ()
- (NSString *)URLString;
- (void)handleEvent:(PTPusherEvent *)event;
- (void)connect;

- (void)sendToSocket:(NSString *)message;
- (void)sendEvent:(NSString *)eventName data:(NSDictionary *)dataLoad;
- (void)sendEventPayload:(NSDictionary *)payLoad;

- (void)_subscribeToAllChannels;
- (void)_subscribeChannel:(PTPusherChannel *)channel;

@property (nonatomic, readonly) NSString *URLString;
@property (nonatomic, readonly) NSMutableDictionary *channels;
@property (nonatomic, readonly) NSMutableArray *subscribeQueue;

@end

#pragma mark -

@implementation PTPusher

@synthesize APIKey;
@synthesize socketID;
@synthesize host;
@synthesize port;
@synthesize delegate;
@synthesize reconnect;
@synthesize channels;
@synthesize subscribeQueue;

@dynamic URLString;

- (id)initWithKey:(NSString *)key delegate:(id <PTPusherDelegate, PTPusherChannelDelegate>)_delegate
{
	if ((self = [super init])) {
		APIKey  = [key copy];
		host = [@"ws.pusherapp.com" copy];
		port = 80;
		delegate = _delegate;
		reconnect = NO;
		
		channels = [[NSMutableDictionary alloc] initWithCapacity:5];
		subscribeQueue = [[NSMutableArray alloc] initWithCapacity:5];
		
		eventListeners = [[NSMutableDictionary alloc] init];
		eventBlockListeners = [[NSMutableDictionary alloc] init];

		socket = [[ZTWebSocket alloc] initWithURLString:self.URLString delegate:self];
		[self connect];
	}
	return self;
}

- (void)dealloc
{
	[socket close];
	[socket release];
	
	[APIKey release];
	
	[channels release];
	[subscribeQueue release];
	
	[eventListeners release];
	[eventBlockListeners release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private

- (void)_subscribeToAllChannels
{
	for (PTPusherChannel *channel in subscribeQueue) {
		[self _subscribeChannel:channel];
	}
	
	[subscribeQueue removeAllObjects];
}

- (void)_subscribeChannel:(PTPusherChannel *)channel
{
	if (channel != nil) {
		if (socket.connected) {
			
			NSMutableDictionary *dataLoad = [NSMutableDictionary dictionary];
			[dataLoad setObject:channel.name forKey:@"channel"];
			
			if (channel.isPrivate || channel.isPresence) {
				[channel authenticateWithSocketID:self.socketID];
			} else {
				[self sendEvent:@"pusher:subscribe" data:dataLoad];
            }
		}
		
		[channels setObject:channel forKey:channel.name];
	}
}

- (void)channelDidAuthenticate:(PTPusherChannel *)channel withReturnData:(NSData *)returnData {
    NSMutableDictionary *dataLoad = [NSMutableDictionary dictionary];
    [dataLoad setObject:channel.name forKey:@"channel"];
    BOOL shouldContinue = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(channel:continueSubscriptionWithAuthResponse:)])
        shouldContinue = [self.delegate channel:channel continueSubscriptionWithAuthResponse:returnData];
    
    if (shouldContinue) {
        NSString *dataString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
        NSDictionary *messageDict = [dataString JSONValue];
        
        [dataLoad addEntriesFromDictionary:messageDict];
        [self sendEvent:@"pusher:subscribe" data:dataLoad];
    }
}

- (void)_unsunscribeChannel:(PTPusherChannel *)channel
{
	if (channel != nil) {
		if (socket.connected) {
			NSDictionary *dataLoad = [NSDictionary dictionaryWithObject:channel.name forKey:@"channel"];
			
			[self sendEvent:@"pusher:unsubscribe" data:dataLoad];
		}
		
		[channels removeObjectForKey:channel.name];
	}
}

#pragma mark -
#pragma mark Subscription Methods

- (PTPusherChannel *)subscribeToChannel:(NSString *)name withAuthPoint:(NSURL *)authPoint delegate:(id <PTPusherDelegate, PTPusherChannelDelegate>)_delegate
{
	PTPusherChannel *channel = [channels objectForKey:name];
	
  if (!channel) {
    channel = [[[PTPusherChannel alloc] initWithName:name pusher:self] autorelease];
  }	
	
	channel.authPoint = authPoint;
	channel.delegate = _delegate;
	
	if (socket.connected) {
    [self _subscribeChannel:channel];
  } else {
    [subscribeQueue addObject:channel]; 
  }
	
	return channel;
}

- (void)unsubscribeFromChannel:(PTPusherChannel	*)channel
{
	[self _unsunscribeChannel:channel];
}

- (PTPusherChannel *)channelWithName:(NSString *)name
{
	return [self.channels objectForKey:name];
}

#pragma mark -
#pragma mark Socket Messaging

- (void)sendToSocket:(NSString *)message
{
	[socket send:message];
}

- (void)sendEvent:(NSString *)eventName data:(NSDictionary *)dataLoad
{
	NSMutableDictionary *payload = [NSMutableDictionary dictionary];
	[payload setObject:eventName forKey:@"event"];
	[payload setObject:dataLoad forKey:@"data"];
	
	[self sendEventPayload:payload];
}

- (void)sendEventPayload:(NSDictionary *)payload
{
	NSString *plString = [payload JSONRepresentation];
	
	[self sendToSocket:plString];
}

#pragma mark -
#pragma mark Event listening

- (void)addEventListener:(NSString *)eventName block:(void (^)(PTPusherEvent *event))block
{
	NSMutableArray *listeners = [eventBlockListeners objectForKey:eventName];
	
	if (listeners == nil) {
		listeners = [NSMutableArray array];
		[eventBlockListeners setObject:listeners forKey:eventName];
	}
	
	[listeners addObject:[[block copy] autorelease]];
}

- (void)addEventListener:(NSString *)eventName target:(id)target selector:(SEL)selector
{
	NSMutableArray *listeners = [eventListeners objectForKey:eventName];
	
	if (listeners == nil) {
		listeners = [NSMutableArray array];
		[eventListeners setValue:listeners forKey:eventName];
	}
	
	PTEventListener *listener = [[[PTEventListener alloc] initWithTarget:target selector:selector] autorelease];
	[listeners addObject:listener];
}

#pragma mark -
#pragma mark Event handling

- (void)handleEvent:(PTPusherEvent *)event
{
	NSArray *listenersForEvent = [eventListeners objectForKey:event.name];
	
	for (PTEventListener *listener in listenersForEvent) {
		[listener performSelectorOnMainThread:@selector(dispatch:) withObject:event waitUntilDone:YES];
	}
	
	NSArray *blockListenersForEvent = [eventBlockListeners objectForKey:event.name];
	
	for (void (^block)(PTPusherEvent *event) in blockListenersForEvent) {
		block(event);
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PTPusherEventReceivedNotification object:event];

	if (event.channel != nil) {
		PTPusherChannel *channel = [self channelWithName:event.channel];		
		[channel eventReceived:event];
	}
}

#pragma mark -
#pragma mark ZTWebSocketDelegate methods

- (void)webSocket:(ZTWebSocket*)webSocket didFailWithError:(NSError*)error
{
	if ([delegate respondsToSelector:@selector(pusherDidFailToConnect:withError:)]) {
		[delegate pusherDidFailToConnect:self withError:error];
	}
	
	if (self.reconnect) {
		if ([delegate respondsToSelector:@selector(pusherWillReconnect:afterDelay:)]) {
			[delegate pusherWillReconnect:self afterDelay:kPTPusherReconnectDelay];
		}
		[self performSelector:@selector(connect) withObject:nil afterDelay:kPTPusherReconnectDelay];
		
		// Move channels to subscribe queue
		for (NSString *key in channels) {
			PTPusherChannel *channel = [channels objectForKey:key];
			[subscribeQueue addObject:channel];
		}
		[channels removeAllObjects];
	}
}

- (void)webSocketDidOpen:(ZTWebSocket*)webSocket
{
	if ([delegate respondsToSelector:@selector(pusherDidConnect:)]) {
		[delegate pusherDidConnect:self];
	}
}

- (void)webSocketDidClose:(ZTWebSocket*)webSocket
{
	if ([delegate respondsToSelector:@selector(pusherDidDisconnect:)]) {
		[delegate pusherDidDisconnect:self];
	}

	if (self.reconnect) {
		if ([delegate respondsToSelector:@selector(pusherWillReconnect:afterDelay:)]) {
			[delegate pusherWillReconnect:self afterDelay:kPTPusherReconnectDelay];
		}
		[self performSelector:@selector(connect) withObject:nil afterDelay:kPTPusherReconnectDelay];
		
		// Move channels to subscribe queue
		for (NSString *key in channels) {
			PTPusherChannel *channel = [channels objectForKey:key];
			[subscribeQueue addObject:channel];
		}
		[channels removeAllObjects];
	}
}

- (void)webSocket:(ZTWebSocket*)webSocket didReceiveMessage:(NSString*)message
{
//	NSLog(@"\nReceived Socket Message:\n%@", message);
	
	id messageDictionary = [message JSONValue];
	PTPusherEvent *event = [[PTPusherEvent alloc] initWithDictionary:messageDictionary];
  
	if ([event.name isEqualToString:@"pusher:connection_established"]) {
		socketID = [[event.data valueForKey:@"socket_id"] retain];
		
		[self _subscribeToAllChannels];
	}
	
	else if ([event.name isEqualToString:@"pusher:connection_disconnected"]) {
		if ([delegate respondsToSelector:@selector(pusherDidDisconnect:)]) {
			[delegate pusherDidDisconnect:self];
		}
	}
	
	else if ([event.name isEqualToString:@"pusher:error"]) {
//		NSLog([event description], nil);
	}
	
	[self handleEvent:event];
	
	[event release];
}

#pragma mark -
#pragma mark Private methods

- (NSString *)URLString
{
//	if (self.channel != nil)
//		return [NSString stringWithFormat:@"ws://%@:%d/app/%@?channel=%@", self.host, self.port, self.APIKey, self.channel];
	
	return [NSString stringWithFormat:@"ws://%@:%d/app/%@", self.host, self.port, self.APIKey];
}

- (void)connect
{
	if ([delegate respondsToSelector:@selector(pusherWillConnect:)]) {
		[delegate pusherWillConnect:self];
	}
	
	[socket open];
}

#pragma mark -
#pragma mark Accessor Methods

static NSString *sharedKey = nil;
static NSString *sharedSecret = nil;
static NSString *sharedAppID = nil;

+ (NSString *)key
{
	return sharedKey;
}

+ (void)setKey:(NSString *)apiKey
{
	[sharedKey release];
	sharedKey = [apiKey copy];
}

+ (NSString *)secret
{
	return sharedSecret;
}

+ (void)setSecret:(NSString *)secret
{
	[sharedSecret release];
	sharedSecret = [secret copy];
}

+ (NSString *)appID
{
	return sharedAppID;
}

+ (void)setAppID:(NSString *)appId
{
	[sharedAppID release];
	sharedAppID = [appId copy];
}

@end
