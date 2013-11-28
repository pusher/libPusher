# libPusher

[![Build Status](https://travis-ci.org/lukeredpath/libPusher.png)](https://travis-ci.org/lukeredpath/libPusher)

An Objective-C client library for the [Pusher.com](http://pusher.com) real-time service. 

Pusher is a hosted service that sits between your web application and the browser that lets you deliver events in real-time using HTML5 WebSockets.

The libPusher API mirrors the Pusher Javascript client as closely as possible, with some allowances for Objective-C conventions. In particular, whilst the Javascript client uses event binding for all event handling, where events are pre-defined, libPusher uses the standard Cocoa delegation pattern.

## Example
Subscribe to the ```chat``` channel and bind to the ```new-message``` event.

```
// _client is a strong instance variable of class PTPusher
_client = [PTPusher pusherWithKey:@"YOUR_API_KEY" delegate:self encrypted:YES];
    
// subscribe to channel and bind to event
PTPusherChannel *channel = [_client subscribeToChannelNamed:@"chat"];
[channel bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *channelEvent) {
	// channelEvent.data is a NSDictianary of the JSON object received
    NSString *message = [channelEvent.data objectForKey:@"text"];
	NSLog(@"message received: %@", message);
}];
```

## Installation

Install using CocoaPods.

```
pod 'libPusher', '~> 1.4'
```

Import Pusher into the class that wants to make use of the library.

```
#import <libPusher/libPusher.h>
```
A step-by-step guide on how to [install and setup CocoaPods]() to use libPusher is available on the wiki.


## Usage

**Note**: in the following examples, ```_client``` is a strong instance variable. The instance returned by the```pusherWithKey:*:``` methods will be auto-released, according to standard Objective-C return conventions. You must retain the client otherwise it will be auto-released before anything useful happens causing silent failures and unexpected behaviour.


### Create a connection

```
_client = [PTPusher pusherWithKey:@"YOUR_API_KEY" delegate:self encrypted:YES];
```
When calling the above method, the connection will be established immediately. 
If you want to defer connection, you can do so:

```
_client = [PTPusher pusherWithKey:@"YOUR_API_KEY" connectAutomatically:NO encrypted:YES];
```
When you are ready to connect, call

```
[_client connect]
```

It is recommended to implement the PTPusherDelegate protocol in order to be notified when significant connection events happen such as connection errors, disconnects and retries.

----------

### Subscribe to channels

Channels are a way of filtering the events you want your application to receive. In addition, private and presence channels can be used to control access to events and in the case of presence channels, see who else is subscribing to events. For more information on channels, see the Pusher documentation.

There is no need to wait for the client to establish a connection before subscribing. You can subscribe to a channel immediately and any subscriptions will be created once the connection has connected.

#### Subscribing to public channels

```
PTPusherChannel *channel = [_client subscribeToChannelNamed:@"chat"];
```

#### Subscribing to private channels

This method will add the appropriate ```private-``` prefix to the channel name for you and return a channel cast to the correct PTPusherChannel subclass PTPusherPrivateChannel.

Subscribing to private channels needs server-side authorisation. See section [Channel Authorisation](#channel-auth) for details.

```
// subsribe to private-chat channel
PTPusherPrivateChannel *private = [_client subscribeToPrivateChannelNamed:@"chat"];
```

#### Subscribing to presence channels

This method will add the appropriate ```presence-``` prefix to the channel name for you and return a channel cast to the correct PTPusherChannel subclass PTPusherPresenceChannel.

Subscribing to presence channels needs server-side authorisation. See section [Channel Authorisation](#channel-auth) for details.

```
// subsribe to presence-chat channel
PTPusherPresenceChannel *presence = [client subscribeToPresenceChannelNamed:@"chat" delegate:self];
```

It is recommended to implement ```PTPusherPresenceChannelDelegate``` protocol, to receive notifications for members subscribing or unsubscribing from the presence channel. 

### Unsubscribe from channels

If you no longer want to receive event over a channel, you can unsubscribe.

```
[_client unsubscribeFromChannel:channel];
```

### <a id="channel-auth"></a>Channel authorisation

Private and presence channels require server-side authorisation before they can connect. 

**Note**: Make sure your server responds correctly to the authentication request. See the [authentication signature](http://pusher.com/docs/auth_signatures) and [user authentication](http://pusher.com/docs/authenticating_users) docs for details and examples on how to implement authorization on the server side.

In order to connect to a private or presence channel, you first need to configure your server authorisation URL.

```
_client.authorizationURL = [NSURL URLWithString:@"http://www.yourserver.com/authorise"];
```

When you attempt to connect to a private or presence channel, libPusher will make a form-encoded POST request to the above URL, passing along the ```socket_id``` and ```channel_name``` as parameters. Prior to sending the request, the Pusher delegate will be notified, passing in the NSMutableURLRequest instance that will be sent.

Its up to you to configure the request to handle whatever authentication mechanism you are using. In this example, we simply set a custom header with a token which the server will use to authenticate the user before proceeding with authorisation.

```
- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
{
	[request setValue:@"some-authentication-token" forHTTPHeaderField:@"X-MyCustom-AuthTokenHeader"];
}
```


----------

### Binding to events

There are generally two ways to bind to events: Binding to an event on the PTPusher client itself or binding to a specific channel. 

#### Binding to a channel
Once you have created an instance of PTPusherChannel, you can set up event bindings. There is no need to wait for the PTPusher client connection to be established.

When you bind to events on a single channel, you will only receive events with that name if they are sent over this channel.

```
PTPusherChannel *channel = [_client subscribeToChannelNamed:@"chat"];
[channel bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *channelEvent) {
  // channelEvent.data is a NSDictianary of the JSON object received
}];
```

#### Binding directly to the client
Once you have created an instance of the PTPusher client, you can set up event bindings. There is no need to wait for the connection to be established.

When you bind to events on the client, you will receive all events with that name, regardless of the channel from which they originated.

```
[_client bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *event) {
  // event.data is a NSDictianary of the JSON object received
}];
```

#### Remove bindings

If you no longer want to receive events with a specific name, you can remove the binding. Removing a binding is as simple as storing a reference to the binding object, then passing that as an argument to ```removeBinding:``` at a later point.

```
_binding = [_client bindToEventNamed:@"new-message" target:self action:@selector(handleEvent:)];

// later
[_client removeBinding:_binding];   
``` 

#### Binding to all events

In some cases it might be useful to bind to all events of a client or channel.
libPusher will publish a ```NSNotification``` for every event received. You can subscribe to all events for a client or channel by adding a notification observer.

Binding to all events using NSNotificationCenter:

```
[[NSNotificationCenter defaultCenter] 
          addObserver:self 
             selector:@selector(didReceiveEventNotification:) 
                 name:PTPusherEventReceivedNotification 
               object:_client];
```

Bind to all events on a single channel:

```
// get chat channel
PTPusherChannel *channel = [_client channelNamed:@"chat"];

[[NSNotificationCenter defaultCenter] 
          addObserver:self 
             selector:@selector(didReceiveChannelEventNotification:) 
                 name:PTPusherEventReceivedNotification 
               object:channel];
```

The event can be retrieved in your callback from the notification's userInfo dictionary. The notification's object will be either the client or channel from which the event originated.

```
- (void)didReceiveEventNotification:(NSNotification *)notification
{
	PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
}
```

## Handling network connectivity errors and disconnects

The nature of a mobile device is that connections will come and go. There are a number of things you can do do ensure that your Pusher connection remains active for as long as you have a network connection and reconnects after network connectivity has been re-established.

The following examples use Apple's Reachability class (version 2.2) to check the network reachability status. Apple recommends that in most circumstances, you do not do any pre-flight checks and simply try and open a connection. This example follows this advice.

You can configure libPusher to automatically try and re-connect if it disconnects or it initially fails to connect.

```
_client = [PTPusher pusherWithKey:@"YOUR_API_KEY" delegate:self encrypted:YES];
_client.reconnectAutomatically = YES;
_client.reconnectDelay = 30; // defaults to 5 seconds
```

What you don't want to do is keep on blindly trying to reconnect if there is no available network and therefore no possible way a connection could be successful. You should implement the ```PTPusherDelegate``` methods ```pusher:connectionDidDisconnect:``` and ```pusher:connection:didFailWithError:```.

```
- (void)pusher:(PTPusher *)client connectionDidDisconnect:(PTPusherConnection *)connection
{
	Reachability *reachability = [Reachability reachabilityForInternetConnection];

	if ([reachability currentReachabilityStatus] == NotReachable) {
		// there is no point in trying to reconnect at this point
		_client.reconnectAutomatically = NO;

		// start observing the reachability status to see when we come back online
		[[NSNotificationCenter defaultCenter] 
				addObserver:self 
             	   selector:@selector(reachabilityChanged:) 
                 	   name:kReachabilityChangedNotification]
               		 object:reachability];

	    [reachability startNotifier];
  	}
}
```

The implementation of ```pusher:connection:didFailWithError:``` will look similar to the above although you may wish to do some further checking of the error.

Now you simply need to wait for the network to become reachable again. There is no guarantee that you will be able to establish a connection but it is an indicator that it would be reasonable to try again.

```
- (void)reachabilityChanged:(NSNotification *)notification
{
	Reachability *reachability = notification.object;

	if ([reachability currentReachabilityStatus] != NotReachable) {
		// we seem to have some kind of network reachability, try to connect again
		[_client connect];

		// we can stop observing reachability changes now
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[reachability stopNotifier];

		// re-enable auto-reconnect
		_client.reconnectAutomatically = YES;
  	}
}
```

Finally, you may prefer to not turn on automatic reconnection immediately, but instead wait until you've successfully connected. You could do this by implementing the ```pusher:connectionDidConnect:``` delegate method:

```
- (void)pusher:(PTPusher *)client connectionDidConnect:(PTPusherConnection *)connection
{
	_client.reconnectAutomatically = YES;
}
```

Doing it this way means you do not need to re-enable auto-reconnect in your Reachability notification handler as it will happen automatically once you have connected.

If Pusher disconnects but Reachability indicates that the network is reachable, it is possible that there is a problem with the Pusher service or something is interfering with the connection. In this situation, you would be advised to simply allow libPusher to try and reconnect automatically (if you have enabled this).

You may want to implement the ```pusher:connectionWillReconnect:afterDelay:``` delegate method and keep track of the number of retry attempts and gradually back off your retry attempts by increasing the reconnect delay after a number of retry attempts have failed. This stops you from constantly trying to connect to Pusher while it is experiencing issues.

## License
All code is licensed under the MIT license. See the LICENSE file for more details.
