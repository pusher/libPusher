//
//  PTPusherPrivateChannel.m
//  libPusher
//
//  Created by Juan Alvarez on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PTPusherPrivateChannel.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "JSON.h"

NSString* const PTPusherPrivateChannelAuthPointException = @"PTPusherPrivateChannelAuthPointException";

@implementation PTPusherPrivateChannel

@synthesize authPointURL, authParams;

- (id)initWithName:(NSString *)channelName 
			 appID:(NSString *)_id 
			   key:(NSString *)_key 
			secret:(NSString *)_secret 
		 authPoint:(NSURL *)_authPoint
		authParams:(NSDictionary *)_authParams
		  delegate:(id<PTPusherPrivateChannelDelegate,PTPusherChannelDelegate>)_delegate
{
	if ([channelName rangeOfString:@"private-" options:NSCaseInsensitiveSearch].location == NSNotFound)
		channelName = [NSString stringWithFormat:@"private-%@", channelName];
	
	if (self = [super initWithName:channelName appID:_id key:_key secret:_secret]) {
		if (_authPoint == nil)
			[NSException raise:PTPusherPrivateChannelAuthPointException format:@"Authentication URL should not be nil"];
		
		self.delegate = _delegate;
		self.authPointURL = _authPoint;
		self.authParams = _authParams;
	}
	
	return self;
}

- (void)dealloc
{
	[authPointURL release];
	[authParams release];
	
	[super dealloc];
}

- (void)startListeningForEvents;
{
	[pusher release];
	pusher = [[PTPusher alloc] initWithKey:APIKey channel:nil];
	pusher.delegate = self;
	pusher.reconnect = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedEventNotification:) name:PTPusherEventReceivedNotification object:nil];
}

#pragma mark -
#pragma mark Private

- (void)authenticateWithSocketID:(NSString *)_socketID
{
	NSMutableString *queryString = [NSMutableString stringWithFormat:@"%@?", [authPointURL absoluteString]];
	[queryString appendFormat:@"channel_name=%@&socket_id=%@", name, _socketID];
	
	for (NSString *key in self.authParams) {
		NSString *value = [self.authParams objectForKey:key];
		
		[queryString appendFormat:@"&%@=%@", key, value];
	}
		
	NSURL *paramsURL = [NSURL URLWithString:queryString];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paramsURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
	[request setHTTPMethod:@"POST"];
	
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	[connection start];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(privateChannelAuthenticationStarted:)])
		[delegate performSelector:@selector(privateChannelAuthenticationStarted:) withObject:self];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSDictionary *messageDict = [dataString JSONValue];
	NSLog([messageDict description], nil);
	
	NSMutableDictionary *dataLoad = [NSMutableDictionary dictionary];
	[dataLoad setObject:name forKey:@"channel"];
	[dataLoad setObject:[messageDict objectForKey:@"auth"] forKey:@"auth"];
	
	NSMutableDictionary *payload = [NSMutableDictionary dictionary];
	[payload setObject:@"pusher:subscribe" forKey:@"event"];
	[payload setObject:dataLoad forKey:@"data"];
	
	NSString *plString = [payload JSONRepresentation];
	
	[pusher sendToSocket:plString];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(privateChannelAuthenticationFailed:withError:)])
		[delegate performSelector:@selector(privateChannelAuthenticationFailed:withError:) withObject:self withObject:error];
}

- (void)receivedEventNotification:(NSNotification *)note;
{
	PTPusherEvent *event = (PTPusherEvent *)note.object;
	NSLog(@"%@", event);
	
	if ([event.name isEqualToString:@"connection_established"]) {
		NSString *_socketid = pusher.socketID;
		
		[self authenticateWithSocketID:_socketid];
	}
}


@end
