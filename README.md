# libPusher, an Objective-C client for Pusher

[Pusher](http://pusherapp.com/) by [New Bamboo](http://new-bamboo.co.uk) is a hosted service that sits between your web application and the browser that lets you deliver events in real-time using HTML5 WebSockets.

This project was borne out of the idea that a web browser doesn't have to be the only client that receives your web app's real-time notifications. Why couldn't your iPhone, iPad or Mac OSX app receive real-time notifications either?

Apple provides its own push notification service which is great for getting alert-type notifications to your app's users whether or not they are using the app, but for real-time updates to data whilst they are using your app, hooking into your web app's existing event-dispatch mechanism is far less hassle (and is great if you want to be able to interact with other web services that might not have access to the APNS).

## Update: August 2011

A large update was made to this library in August 2011 that is not backwards compatible with previous-versions of this library. Users are advised to take the time to update their code to use the new API, which now mirrors more closely the Pusher Javascript API and will be more stable going forwards.

The major changes are:

* Re-architected the core API to bring it in line with the Javascript API.
* Support multiple channels over a single connection.
* Added support for private and presence channels.
* Added block-support for event callbacks.
* Extracted the wrapper for the Pusher REST API into a standalone component.
* Dropped support for iOS 3.0

## Installation instructions

The libPusher Xcode project contains a static library target that lets you compile a static library for use in your own 
applications. There are several ways of getting this static library into your application: one convenient way would be to import the libPusher Xcode project into your own Xcode project as a cross-project reference. This will ensure the latest static library gets built whenever your app is built and means you can refer to Git clone of the project and keep up-to-date with the latest changes.

For more detailed instructions on adding a static library via an Xcode cross-project reference, please refer to [this guide](http://www.amateurinmotion.com/articles/2009/02/08/creating-a-static-library-for-iphone.html), starting from the section "Linking against static library". You will need to remember to update your project's header search path so it can find the header files if you haven't added them directly to your project.

Alternatively, you can simply copy the relevant files (all the files in the Library folder, plus all of the files in Vendor) into your project although you will need to take care of updating the files with changes yourself.

In addition to the above instructions, you will need to add `-all_load` to your build settings under "Other linker flags", to ensure the categories defined by the library are loaded.

### Building notes

The project includes the Zimt library as a Git submodule; you'll need to init your Git submodules before you are able to build. 

    $ git submodule update --init --recursive
    
To build and run the sample app, you'll need to create a Constants.h file containing your Pusher API key, app ID and secret key; see the sample application app delegate for instructions.

## Getting started

The libPusher API mirrors the [Pusher Javascript client](http://pusher.com/docs/client_api_guide) as closely as possible, with some allowances for Objective-C conventions. In particular, whilst the Javascript client uses event binding for all event handling, where events are pre-defined, libPusher uses the standard Cocoa delegation pattern.

### Creating a new connection

Establishing a connection to Pusher is as simple as passing in your API key and a delegate to one of the built-in convenience factory methods:

```objc
PTPusher *client = [PTPusher pusherWithKey:@"YOUR-API-KEY" delegate:self];
```

When calling the above method, the connection will be established immediately. If you want to defer connection, you can do so:

```objc
PTPusher *client = [PTPusher pusherWithKey:@"YOUR-API-KEY" connectAutomatically:NO];
```

You can then connect when you are ready by calling `connect`.

It is recommend you assign a delegate to the Pusher client as this will enable you to be notified when significant connection events happen such as connection errors, disconnects and retries.

If you want to have your connection reconnect automatically when it disconnects, you can:

```objc
client.reconnectAutomatically = YES;

// optional, defaults to 5 seconds
client.reconnectDelay = 1.0;
```

### Binding to events

Once you have created an instance of the Pusher client, you can set up event bindings; there is no need to wait for the connection to be established.

When you bind to events on the client, you will receive all events with that name, regardless of the channel from which they originated.

There are two ways of binding to individual events; using the standard Cocoa target/action mechanism, or using blocks. Use whatever makes sense within the context of your application.

Binding to events using target/action:

```objc
[client bindToEventNamed:@"something-happened" target:self action:@selector(handleEvent:)];
```

Binding to events using blocks:

```objc
[client bindToEventNamed:@"something-happened" handleWithBlock:^(PTPusherEvent *event) {
  // do something with event
}];
```

## Working with channels

Channels are a way of filtering the events you want your application to receive. In addition, private and presence channels can be used to control access to events and in the case of presence channels, see who else is subscribing to events. For more information on channels, [see the Pusher documentation](http://pusher.com/docs/client_api_guide/client_channels).

### Subscribing and unsubscribing

Channels of any type can be subscribed to using the method `subscribeToChannelNamed:`. When subscribing to private or presence channels, it's important to remember to add the appropriate channel name prefix.

You do not need to wait for the client to establish a connection before subscribing; you can subscribe immediately and any subscriptions will be created once the connection has connected.

```objc
// subscribe to public channels
PTPusherChannel *channel = [client subscribeToChannelNamed:@"my-public-channel"];

// subscribe to private or presence channels with the appropriate prefix
PTPusherChannel *private = [client subscribeToChannelNamed:@"private-channel"];
PTPusherChannel *presence = [client subscribeToChannelNamed:@"presence-channel"];
```
As a convenience, two methods are provided specifically for subscribing to private and presence channels. These methods will add the appropriate prefix to the channel name for you and return a channel casted to the correct PTPusherChannel sub-class. You can also set a presence delegate for presence channels using this API.

```objc
// subscribe to private channel, private- prefix added automatically
PTPusherPrivateChannel *private = [client subscribeToPrivateChannelNamed:@"demo"];

// subscribe to presence channel with a delegate, presence- prefix added automatically
PTPusherPresenceChannel *presence = [client subscribeToPresenceChannelNamed:@"chat" delegate:self];
```
Any channel that has been previously subscribed to can be retrieved (without re-subscribing) using the `channelNamed:` method. You can unsubscribe a channel by calling `unsubscribeFromChannel:`.

```objc
// get a reference to a channel we have already subscribed to
PTPusherChannel *channel = [client channelNamed:@"my-channel"];

// now unsubscribe from it
[client unsubscribeFromChannel:channel];
```

### Binding to channel events

Binding to events on channels works in exactly the same way as binding to client events; the only difference is that you will only receive events with that are associated with that channel.

```objc
// subscribe to the channel
PTPusherChannel *channel = [client subscribeToChannelNamed:@"demo"];

// now bind to some events on that channel
[channel bindToEventNamed:@"channel-event" handleWithBlock:^(PTPusherEvent *channelEvent) {
  // do something with channel event
}];
```

## Binding to all events

Unlike the Javascript client, libPusher does not provide an explicit API for binding to all events from a client or channel. Instead, libPusher will publish a `NSNotification` for every event received. You can subscribe to all events for a client or channel by adding a notification observer.

```objc
// bind to all events received by the client
[[NSNotificationCenter defaultCenter] 
          addObserver:self 
             selector:@selector(didReceiveEventNotification:) 
                 name:PTPusherEventReceivedNotification 
               object:client];
               
// bind to all events on a specific channel
PTPusherChannel *channel = [client channelNamed:@"some-channel"];

[[NSNotificationCenter defaultCenter] 
          addObserver:self 
             selector:@selector(didReceiveChannelEventNotification:) 
                 name:PTPusherEventReceivedNotification 
               object:channel];
```

The event can be retrieved in your callback from the notification's `userInfo` dictionary. The notification's `object` will be either the client or channel from which the event originated.

```objc
- (void)didReceiveEventNotification:(NSNotification *)note
{
  PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
  // do something with event
}
```

## Credits

PusherTouch uses the [ZTWebSocket](http://github.com/openresearch/zimt) library by [OpenResearch](http://github.com/openresearch), without which I probably wouldn't have got anywhere.
[Pusher](http://pusherapp.com) is a [New Bamboo](http://new-bamboo.co.uk) product.

## License

All code is licensed under the MIT license. See the LICENSE file for more details.
