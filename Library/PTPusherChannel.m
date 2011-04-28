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
#import "PTEventListener.h"
#import "JSON.h"
#import "NSString+Hashing.h"
#import "NSDictionary+QueryString.h"
#import "PTTransaction.h"

#import <CommonCrypto/CommonHMAC.h>

#define kPTPusherWebServiceHost @"api.pusherapp.com"

#define kSubscriptionSucceededPresenceKey @"pusher_internal:subscription_succeeded"
#define kMemberAddedPresenceKey @"pusher_internal:member_added"
#define kMemberRemovedPresenceKey @"pusher_internal:member_removed"

NSString *generateEncodedHMAC(NSString *string, NSString *secret) {
	const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
	const char *cData = [string cStringUsingEncoding:NSASCIIStringEncoding];
    
	unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
	CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
	NSMutableString *result = [[NSMutableString alloc] init];
	for (int i = 0; i < sizeof(cHMAC); i++) {
		[result appendFormat:@"%02x", cHMAC[i] & 0xff];
	}
	NSString *digest = [result copy];
	[result release];
    
	return [digest autorelease];
}

NSString *URLEncodedString(NSString *unencodedString) {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                               NULL, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

@interface PTPusherChannel ()
@property (nonatomic, readwrite, retain) NSMutableSet *transactions;
- (PTTransaction *)_transactionForConnection:(NSURLConnection *)connection;
@end

@implementation PTPusherChannel

@synthesize name, authPoint;
@synthesize pusher;
@synthesize delegate;
@synthesize transactions = _transactions;

@dynamic isPrivate, isPresence;

- (id)initWithName:(NSString *)_name pusher:(PTPusher *)_pusher
{
	if ((self = [super init])) {
        self.transactions = [NSMutableSet set];
		name = [_name copy];
		pusher = _pusher;
		
		operationQueue = [[NSOperationQueue alloc] init];
		delegate = nil;
		
		eventListeners = [[NSMutableDictionary alloc] init];
		eventBlockListeners = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)dealloc
{	
    self.transactions = nil;
	pusher = nil;
	
	[name release];
	[operationQueue release];
	[authPoint release];
	
	[eventListeners release];
	eventListeners = nil;
	
	[eventBlockListeners release];
	eventBlockListeners = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private

#if NS_BLOCKS_AVAILABLE
- (void)_addBlockListener:(void (^)())block forEvent:(NSString *)eventName
{
	NSMutableArray *listeners = [eventBlockListeners objectForKey:eventName];
	
	if (listeners == nil) {
		listeners = [NSMutableArray array];
		[eventBlockListeners setObject:listeners forKey:eventName];
	}
	
	[listeners addObject:[[block copy] autorelease]];
}
#endif

- (void)_addEventListener:(NSString *)eventName target:(id)target selector:(SEL)selector
{
	NSMutableArray *listeners = [eventListeners objectForKey:eventName];
	
	if (listeners == nil) {
		listeners = [NSMutableArray	array];
		[eventListeners setValue:listeners forKey:eventName];
	}
	
	PTEventListener *listener = [[[PTEventListener alloc] initWithTarget:target selector:selector] autorelease];
	[listeners addObject:listener];
}

#pragma mark -
#pragma mark Event Listening

#if NS_BLOCKS_AVAILABLE
- (void)addEventListener:(NSString *)eventName block:(void (^)(PTPusherEvent *event))block
{
	[self _addBlockListener:block forEvent:eventName];
}
#endif

- (void)addEventListener:(NSString *)eventName target:(id)target selector:(SEL)selector
{
	[self _addEventListener:eventName target:target selector:selector];
}

#pragma mark -
#pragma mark Presence Channel Listeners

#if NS_BLOCKS_AVAILABLE
- (void)addSubscriptionSucceededEventListener:(void (^)(NSArray *userList))block
{
	[self _addBlockListener:block forEvent:kSubscriptionSucceededPresenceKey];
}

- (void)addMemberAddedEventListener:(void (^)(NSDictionary *memberInfo))block
{
	[self _addBlockListener:block forEvent:kMemberAddedPresenceKey];
}

- (void)addMemberRemovedEventListener:(void (^)(NSDictionary *memberInfo))block
{	
	[self _addBlockListener:block forEvent:kMemberRemovedPresenceKey];
}
#endif

- (void)addSubscriptionSucceededEventListener:(id)target selector:(SEL)selector
{
	[self _addEventListener:kSubscriptionSucceededPresenceKey target:target selector:selector];
}

- (void)addMemberAddedEventListener:(id)target selector:(SEL)selector
{
	[self _addEventListener:kMemberAddedPresenceKey target:target selector:selector];
}

- (void)addMemberRemovedEventListener:(id)target selector:(SEL)selector
{
	[self _addEventListener:kMemberRemovedPresenceKey target:target selector:selector];
}

#pragma mark -
#pragma mark Event handling

- (void)handleEvent:(PTPusherEvent *)event
{
	if ([self.delegate respondsToSelector:@selector(channel:didReceiveEvent:)]) {
		[self.delegate channel:self didReceiveEvent:event];
	}
	
	if ([event.name isEqualToString:kSubscriptionSucceededPresenceKey] || [event.name rangeOfString:@"subscription_succeeded"].location != NSNotFound) {
		SEL selector = @selector(presenceChannelSubscriptionSucceeded:withUserInfo:);
		
		if (self.delegate && [self.delegate respondsToSelector:selector])
			[self.delegate performSelector:selector withObject:self withObject:event.data];
	}
	
	else if ([event.name isEqualToString:kMemberAddedPresenceKey]) {
		SEL selector = @selector(presenceChannel:memberAdded:);
		
		if (self.delegate && [self.delegate respondsToSelector:selector])
			[self.delegate performSelector:selector withObject:self withObject:event.data];
	}
	
	else if ([event.name isEqualToString:kMemberRemovedPresenceKey]) {
		SEL selector = @selector(presenceChannel:memberRemoved:);
		
		if (self.delegate && [self.delegate respondsToSelector:selector])
			[self.delegate performSelector:selector withObject:self withObject:event.data];
	}
	
	NSArray *listenersForEvent = [eventListeners objectForKey:event.name];
	
	for (PTEventListener *listener in listenersForEvent) {
		[listener dispatch:event];
	}
	
	if (eventBlockListeners != nil) {
		NSArray *blockListenersForEvent = [eventBlockListeners objectForKey:event.name];
		
		for (void (^block)() in blockListenersForEvent) {
			if ([event.name isEqualToString:kSubscriptionSucceededPresenceKey] ||
				[event.name isEqualToString:kMemberAddedPresenceKey] ||
				[event.name isEqualToString:kMemberRemovedPresenceKey])
			{
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					block(event.data);
				});
			}
			else
			{
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					block(event);
				});
			}
		}
	}
}

#pragma mark -
#pragma mark Event Triggering

- (void)triggerEvent:(NSString *)event data:(id)data
{
	NSString *path = [NSString stringWithFormat:@"/apps/%@/channels/%@/events", [PTPusher appID], name];
	NSString *body = [data JSONRepresentation];
    
	NSMutableDictionary *queryParameters = [NSMutableDictionary dictionary];
	[queryParameters setValue:[[body MD5Hash] lowercaseString] forKey:@"body_md5"];
	[queryParameters setValue:pusher.APIKey forKey:@"auth_key"];
	[queryParameters setValue:[NSNumber numberWithDouble:time(NULL)] forKey:@"auth_timestamp"];
	[queryParameters setValue:@"1.0" forKey:@"auth_version"];
	[queryParameters setValue:event forKey:@"name"];
	
	if (pusher.socketID != nil)
		[queryParameters setValue:pusher.socketID forKey:@"socket_id"];
    
	NSString *signatureQuery = [queryParameters sortedQueryString];
	NSMutableString *signatureString = [NSMutableString stringWithFormat:@"POST\n%@\n%@", path, signatureQuery];
    
	[queryParameters setValue:generateEncodedHMAC(signatureString, [PTPusher secret]) forKey:@"auth_signature"];
    
	NSString *resourceString = [NSString stringWithFormat:@"http://%@%@?%@", kPTPusherWebServiceHost, path, [queryParameters sortedQueryString]];
    
	PTPusherClientOperation *operation = [[PTPusherClientOperation alloc] initWithURL:[NSURL URLWithString:resourceString] JSONString:body];
	operation.delegate = self.delegate;
	operation.channel = self;
	[operationQueue addOperation:operation];
	[operation release];
}

#pragma mark -
#pragma mark Authentication For Private and Presence Channels

- (void)authenticateWithSocketID:(NSString *)_socketID
{
	NSMutableString *queryString = [NSMutableString stringWithFormat:@"%@?", [self.authPoint absoluteString]];
	[queryString appendFormat:@"channel_name=%@&socket_id=%@", name, _socketID];
	
	NSDictionary *authParams = nil;
	if (self.delegate && [self.delegate respondsToSelector:@selector(extraParamsForChannelAuthentication:)])
		authParams = [self.delegate extraParamsForChannelAuthentication:self];
	
	for (NSString *key in authParams) {
		NSString *value = [authParams objectForKey:key];
		
		[queryString appendFormat:@"&%@=%@", key, value];
	}
	
	NSURL *paramsURL = [NSURL URLWithString:queryString];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paramsURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
	[request setHTTPMethod:@"POST"];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(channel:authenticationWillStartWithRequest:)])
		[self.delegate channel:self authenticationWillStartWithRequest:request];
    
    PTTransaction *transaction = [PTTransaction transaction];
    transaction.request = request;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];

	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	transaction.connection = connection;
	[self.transactions addObject:transaction];
	[connection start];
	[connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[[self _transactionForConnection:connection].receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([self.delegate respondsToSelector:@selector(channel:didReceiveAuthenticationChallenge:)]) {
		[self.delegate channel:self didReceiveAuthenticationChallenge:challenge];
	} else {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		PTTransaction *transaction = [self _transactionForConnection:connection];
		transaction.response = (NSHTTPURLResponse *)response;
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    PTTransaction *transaction = [self _transactionForConnection:connection];
	
    if (self.delegate && [self.delegate respondsToSelector:@selector(channelAuthenticationFailed:)])
        [self.delegate channelAuthenticationFailed:self withError:error];
	
	if ([self.transactions containsObject:transaction])
		[self.transactions removeObject:transaction];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	PTTransaction *transaction = [self _transactionForConnection:connection];
	
    if (self.pusher)
        [self.pusher channelDidAuthenticate:self withReturnData:transaction.receivedData];
    
    if ([self.transactions containsObject:transaction])
		[self.transactions removeObject:transaction];
}

- (PTTransaction *)_transactionForConnection:(NSURLConnection *)connection {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connection = %@", connection];
	NSSet *resultSet = [self.transactions filteredSetUsingPredicate:predicate];
	return [resultSet anyObject];
}

#pragma mark -
#pragma mark Accessor Methods

- (BOOL)isPrivate
{
	if ([self.name rangeOfString:kPrivateChannelPrefix options:NSCaseInsensitiveSearch].location == NSNotFound)
		return NO;
	
	return YES;
}

- (BOOL)isPresence
{
	if ([self.name rangeOfString:kPresenseChannelPrefix options:NSCaseInsensitiveSearch].location == NSNotFound)
		return NO;
	
	return YES;
}

#pragma mark -
#pragma mark Private

- (void)eventReceived:(PTPusherEvent *)event
{
	[self handleEvent:event];
}

@end

@implementation PTPusherClientOperation

@synthesize delegate;
@synthesize channel;

- (id)initWithURL:(NSURL *)_url JSONString:(NSString *)json
{
	if ((self = [super init])) {
		url = [_url copy];
		body = [json copy];
	}
	return self;
}

- (void)dealloc
{
	[url release];
	[body release];
	
	[super dealloc];
}

- (void)main
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
	NSHTTPURLResponse *response = nil;
	NSError *error = nil;
    
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];
    
	if (error != nil) {
		if (self.channel && [self.delegate respondsToSelector:@selector(channelFailedToTriggerEvent:error:)]) {
			[self.delegate channelFailedToTriggerEvent:self.channel error:error];
		}
	} else {
		if ([response statusCode] == 202) {
			if (self.channel && [self.delegate respondsToSelector:@selector(channelDidTriggerEvent:)]) {
				[self.delegate channelDidTriggerEvent:self.channel];
			} 
		} else {
			if (self.channel && [self.delegate respondsToSelector:@selector(channelFailedToTriggerEvent:error:)]) {
				NSError *error = [NSError errorWithDomain:@"PTPusherOperationFailed" code:[response statusCode] userInfo:[NSDictionary dictionaryWithObject:response forKey:@"response"]];
				[self.delegate channelFailedToTriggerEvent:self.channel error:error];
			}
		}    
	}
}

@end

