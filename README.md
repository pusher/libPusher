# libPusher

[![Build Status](https://travis-ci.org/lukeredpath/libPusher.png)](https://travis-ci.org/lukeredpath/libPusher)

An Objective-C client library for the [Pusher.com](http://pusher.com) real-time service. 

Pusher is a hosted service that sits between your web application and the browser that lets you deliver events in real-time using HTML5 WebSockets.

The libPusher API mirrors the Pusher Javascript client as closely as possible, with some allowances for Objective-C conventions. In particular, whilst the Javascript client uses event binding for all event handling, where events are pre-defined, libPusher uses the standard Cocoa delegation pattern.

[API Documentation](http://cocoadocs.org/docsets/libPusher/1.5/)

## Example
Subscribe to the ```chat``` channel and bind to the ```new-message``` event.

```
// self.client is a strong instance variable of class PTPusher
self.client = [PTPusher pusherWithKey:@"YOUR_API_KEY" delegate:self encrypted:YES];
    
// subscribe to channel and bind to event
PTPusherChannel *channel = [self.client subscribeToChannelNamed:@"chat"];
[channel bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *channelEvent) {
	// channelEvent.data is a NSDictianary of the JSON object received
    NSString *message = [channelEvent.data objectForKey:@"text"];
	NSLog(@"message received: %@", message);
}];
```

## Installation

Install using CocoaPods is recommended.

```ruby
pod 'libPusher', '~> 1.6.1'
```

Import Pusher into the class that wants to make use of the library.

```objc
#import <Pusher/Pusher.h>
```

A step-by-step guide on how to [install and setup CocoaPods]() to use libPusher without using CocoaPods is available on the wiki.

If you want to use the ReactiveExtensions version of libPusher, add the following line to your Podfile instead.

```ruby
pod 'libPusher/ReactiveExtensions', '~> 1.6.1'
```

This will also load the core libPusher library and ReactiveCocoa as a dependency.

If you are not using CocoaPods, you can simply drop the extensions into your project.

## Usage

**Note**: in the following examples, ```client``` is a strong property. The instance returned by the ```pusherWithKey:*:``` methods will be auto-released, according to standard Objective-C return conventions. You must retain the client otherwise it will be auto-released before anything useful happens causing silent failures and unexpected behaviour.

### Create a client and connecting

```objc
self.client = [PTPusher pusherWithKey:@"YOUR_API_KEY" delegate:self encrypted:YES];

[self.client connect];
```

Note that client's do not connect automatically (as of version 1.5) - you are responsible for calling connect as needed.

It is recommended to implement the PTPusherDelegate protocol in order to be notified when significant connection events happen such as connection errors, disconnects and retries.

----------

### Subscribe to channels

Channels are a way of filtering the events you want your application to receive. In addition, private and presence channels can be used to control access to events and in the case of presence channels, see who else is subscribing to events. For more information on channels, see the Pusher documentation.

There is no need to wait for the client to establish a connection before subscribing. You can subscribe to a channel immediately and any subscriptions will be created once the connection has connected.

#### Subscribing to public channels

```objc
PTPusherChannel *channel = [self.client subscribeToChannelNamed:@"chat"];
```

#### Subscribing to private channels

This method will add the appropriate ```private-``` prefix to the channel name for you and return a channel cast to the correct PTPusherChannel subclass PTPusherPrivateChannel.

Subscribing to private channels needs server-side authorisation. See section [Channel Authorisation](#channel-authorisation) for details.

```objc
// subscribe to private-chat channel
PTPusherPrivateChannel *private = [self.client subscribeToPrivateChannelNamed:@"chat"];
```

#### Subscribing to presence channels

This method will add the appropriate ```presence-``` prefix to the channel name for you and return a channel cast to the correct PTPusherChannel subclass PTPusherPresenceChannel.

Subscribing to presence channels needs server-side authorisation. See section [Channel Authorisation](#channel-authorisation) for details.

```objc
// subscribe to presence-chat channel
PTPusherPresenceChannel *presence = [client subscribeToPresenceChannelNamed:@"chat" delegate:self];
```

It is recommended to implement ```PTPusherPresenceChannelDelegate``` protocol, to receive notifications for members subscribing or unsubscribing from the presence channel. 

### Accessing subscribed channels

You can use the `channelNamed:` method to retrieve an existing subscribed channel. If you have not subscribed to the requested channel, it will return `nil`.

```objc
// get the 'chat' channel that you've already subscribed to
PTPusherChannel *channel = [self.client channelNamed:@"chat"];
```

### Unsubscribe from channels

If you no longer want to receive event over a channel, you can unsubscribe.

```objc
PTPusherChannel *channel = [self.client channelNamed:@"chat"];
[channel unsubscribe];
```

### Channel object lifetime

When the Pusher client disconnects, all subscribed channels are implicitly unsubscribed (`isSubscribed` will return NO), however the channel objects will persist and so will any event bindings. 

When the client reconnects, all previously subscribed channels will be resubcribed (which might involve another authentication request for any private/presence channels) and your existing event bindings will continue working as they did prior to the disconnection.

If you explicitly unsubscribe from a channel, **all event bindings will be removed and the client will remove the channel object from it's list of subscribed channels**. If no other code has a strong reference to the channel object, it will be deallocated. If you resubscribe to the channel, a new channel object will be created. You should bear this in mind if you maintain any strong references to a channel object in your application code.

### Channel authorisation

Private and presence channels require server-side authorisation before they can connect. 

**Note**: Make sure your server responds correctly to the authentication request. See the [authentication signature](http://pusher.com/docs/auth_signatures) and [user authentication](http://pusher.com/docs/authenticating_users) docs for details and examples on how to implement authorization on the server side.

In order to connect to a private or presence channel, you first need to configure your server authorisation URL.

```objc
self.client.authorizationURL = [NSURL URLWithString:@"https://www.yourserver.com/authorise"];
```

When you attempt to connect to a private or presence channel, libPusher will make a form-encoded POST request to the above URL, passing along the ```socket_id``` and ```channel_name``` as parameters. Prior to sending the request, the Pusher delegate will be notified, passing in the channel and the NSMutableURLRequest instance that will be sent.

Its up to you to configure the request to handle whatever authentication mechanism you are using. In this example, we simply set a custom header with a token which the server will use to authenticate the user before proceeding with authorisation.

```objc
- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withRequest:(NSMutableURLRequest *)request
{
	[request setValue:@"some-authentication-token" forHTTPHeaderField:@"X-MyCustom-AuthTokenHeader"];
}
```

----------

### Binding to events

There are generally two ways to bind to events: Binding to an event on the PTPusher client itself or binding to a specific channel.

Two types of direct binding are supported: target/action and block-based bindings. The examples below using block-based bindings.

#### Binding to a channel

Once you have created an instance of PTPusherChannel, you can set up event bindings. There is no need to wait for the PTPusher client connection to be established or the channel to be subscribed.

When you bind to events on a single channel, you will only receive events with that name if they are sent over this channel.

```objc
PTPusherChannel *channel = [self.client subscribeToChannelNamed:@"chat"];
[channel bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *channelEvent) {
  // channelEvent.data is a NSDictionary of the JSON object received
}];
```

#### Binding directly to the client

When you bind to events on the client, you will receive all events with that name, regardless of the channel from which they originated.

```objc
[self.client bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *event) {
  // event.data is a NSDictionary of the JSON object received
}];
```

#### Remove bindings

If you no longer want to receive events with a specific name, you can remove the binding. Removing a binding is as simple as storing a reference to the binding object, then passing that as an argument to ```removeBinding:``` at a later point.

**Note:** Binding objects are owned by the client or channel that they relate to and will exist for the lifetime of the binding. For this reason, you generally only need to store a weak reference to the binding object in order to remove the binding. In the event that something else removes the binding (perhaps as a result of calling `removeAllBindings` or explicitly unsubscribing from the channel), the weak reference will ensure that the binding object will become nil, so you should check this before calling `removeBinding:`.

```objc
// _binding is a weak reference
_binding = [self.client bindToEventNamed:@"new-message" target:self action:@selector(handleEvent:)];

// check that nothing else has removed the binding already
if (_binding) {
  [self.client removeBinding:_binding];
}
```

#### Memory management considerations for block-based bindings

Similar caveats apply to block-based bindings as they do to using block based `NSNotificationCenter` observers, i.e. when referencing `self` in your event handler block, it is possible in some situations to create retain cycles or prevent `self` from being deallocated.

When you reference `self` in your event handler block, the block will retain a strong reference to `self`. This means that `self` will never be deallocated until the binding (and in turn the event handler block) is destroyed by removing the binding. For this reason, you should be wary about removing event bindings in `dealloc` methods as `dealloc` will never be called if the binding references `self`.

For example, you might push a `UIViewController` on to a `UINavigationController` stack, then create an event binding in that view controller's `viewDidAppear:` method:

```objc
- (void)viewDidAppear:(BOOL)animated
{
  // _binding is a weak instance variable
  _binding = [self.client bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *event) {
    [self doSomethingWithEvent:event];
  }];
}
```

If you were to then pop that view controller off the navigation stack without removing the event binding, because the binding block has a strong reference to `self`, the view controller will never be deallocated and you will have a memory leak.

You can handle this in one of two ways. The first is to ensure you remove the binding when in the corresponding `viewDidDisappear:`

```objc
- (void)viewDidDisappear:(BOOL)animated
{
  [self.client removeBinding:_binding];
}
```

The second, is to prevent a strong reference to `self` being captured in the first place:

````objc
- (void)viewDidAppear:(BOOL)animated
{
  __weak typeof(self) weakSelf = self;
  
  // _binding is a weak instance variable
  _binding = [self.client bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *event) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    [strongSelf doSomethingWithEvent:event];
  }];
}
```

Finally, if you reference `self` in a block and store a *strong* reference to the binding object, you will create a retain cycle (`self` -> `binding` -> `block` -> `self`). You should avoid keeping strong references to binding objects but if you really need to, you should ensure you only capture a weak reference to `self` in the block as in the above example.

#### Binding to all events

In some cases it might be useful to bind to all events of a client or channel.
libPusher will publish a ```NSNotification``` for every event received. You can subscribe to all events for a client or channel by adding a notification observer.

Binding to all events using NSNotificationCenter:

```objc
[[NSNotificationCenter defaultCenter] 
          addObserver:self 
             selector:@selector(didReceiveEventNotification:) 
                 name:PTPusherEventReceivedNotification 
               object:self.client];
```

Bind to all events on a single channel:

```objc
// get chat channel
PTPusherChannel *channel = [self.client channelNamed:@"chat"];

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

### Automatic reconnection behaviour

libPusher will generally try and do it's best to keep you connected in most cases:

* If the connection fails having been previously connected, the client will try and reconnect immediately.
* If the connection disconnects with a Pusher error code in the range 4200-4299, the client will try and reconnect immediately.
* If the connection disconnects with a Pusher error code in the range 4100-4199, the client will try and reconnect with a linear back-off delay.
* If the connection disconnects for an unknown reason, the client will try and reconnect after a configured delay (defaults to 5 seconds and can be changed using the `reconnectDelay` property).

All automatic reconnection attempts will be repeated up to a maximum limit before giving up.

Automatic reconnection will not happen in the following situations:

* The connection fails on the initial attempt (i.e. not previously connected)
* The connection disconnects with a Pusher error code in the range 4000-4099 (indicating a client error, normally a misconfiguration)
* The maximum number of automatic reconnection attempts have been reached

An error code in the range 4000-4099 generally indicates a client misconfiguration (e.g. invalid API key) or rate limiting. See the [Pusher protocol documentation](http://pusher.com/docs/pusher_protocol#error-codes) for more information.

The other scenarios generally indicate that it is not currently possible to connect to the Pusher service - this might be because of an issue with the service but more likely is that there simply isn't an internet connection.

Up to version 1.6, automatic reconnection would happen after the configured `reconnectDelay` even after explicitly 
calling `disconnect`. This behaviour was undesirable and in all subsequent versions this no longer happens and an explicit call to `connect` is required to reconnect in this case.

### Handling disconnections

If the client fails to connect at all, the delegate method `pusher:connection:failedWithError:` will be called and no automatic reconnection will be attempted.

If the client disconnects, the delegate method `pusher:connection:didDisconnectWithError:willAttemptReconnect:` will be called. If `willAttemptReconnect` is `YES`, you don't have any further work to do.

If `willAttemptReconnect` is `NO`, you should first check the error to see if there is a client misconfiguration. If the client is refusing to automatically reconnect due to a Pusher error code, the `NSError` will have a domain of `PTPusherFatalErrorDomain`.

How you handle disconnections is up to you, but the general idea is to check if there is network connectivity and if there is not, wait until there is before reconnecting.

#### Example: handling disconnections using the Reachability library

In this example, we first check for any fatal Pusher errors, before using Reachability to wait for an internet connection to become available before manually reconnecting.

```objc
- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
  [self handleDisconnectionWithError:error];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
  if (!willAttemptReconnect) {
    [self handleDisconnectionWithError:error];
  }
}
```

The implementation of `handleDisconnectionWithError` performs the error check and waits for Reachability to change:

```objc
- (void)handleDisconnectionWithError:(NSError *)error
{
  Reachability *reachability = [Reachability reachabilityWithHostname:self.client.connection.URL.host];
  
  if (error && [error.domain isEqualToString:PTPusherFatalErrorDomain]) {
    NSLog(@"FATAL PUSHER ERROR, COULD NOT CONNECT! %@", error);
  }
  else {
    if ([reachability isReachable]) {
      // we do have reachability so let's wait for a set delay before trying again
      [self.client performSelector:@selector(connect) withObject:nil afterDelay:5];
    }
    else {
      // we need to wait for reachability to change
      [[NSNotificationCenter defaultCenter] addObserver:self 
                                               selector:@selector(_reachabilityChanged:) 
                                                   name:kReachabilityChangedNotification 
                                                 object:reachability];
                                                 
      [reachability startNotifier];
    }
  }
}

- (void)_reachabilityChanged:(NSNotification *note)
{
  Reachability *reachability = [note object];
  
  if ([reachability isReachable]) {
    // we're reachable, we can try and reconnect, otherwise keep waiting
    [self.client connect];
    
    // stop watching for reachability changes
    [reachability stopNotifier];

    [[NSNotificationCenter defaultCenter] 
        removeObserver:self 
                  name:kReachabilityChangedNotification 
                object:reachability];
  }
}
```

For a more sophisticated implementation of handling client disconnections and to see how this integrates with a real application, you could take a look at the `ClientDisconnectionHandler` class in the [official Pusher iOS Diagnostics app](https://github.com/pusher/pusher-test-iOS/).

## License

All code is licensed under the MIT license. See the LICENSE file for more details.
