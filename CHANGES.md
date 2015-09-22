# 1.6.1 - September 2015

* Update SocketRocket to 0.4.1 (#181)
* Update Gemfile to use more recent version of Cocoapods
* Changed iOS deployment target to 6.0

# 1.6 - March 2015

* Swift and 64-bit compatibility
* Added new delegate method to support extracting auth response from wrapped payloads (#171)
* Removed deprecated methods and delegate calls
* Removed SocketRocket from the public interface (#157)
* Fix deprecation warning for willAuthorizeChannelWithRequest (#147)
* Use NSDate instead of C API for setting timestamp on auth request (#133)

# 1.5 - December 2013

This release contains some significant bug fixes and API changes. All deprecated API in this release will be removed in the next release after this one.

## Upgrade notes

This is a summary of the changes in this release and notes on how to upgrade. The recommended way of installing libPusher is to use CocoaPods.

As of this version, support for iOS < 5.0 and OSX < 10.8 has been dropped.

### Connection is no longer automatic

`PTPusher` will no longer connect automatically on initialisation and all methods that accept a connect `connectAutomatically` parameter (including the initialiser and all factory methods) are deprecated. 

You should now explicitly call `connect` when you are ready to connect.

The method `reconnectAutomatically` has been removed completely (see below).

### Improvements to disconnection handling

`PTPusher` now goes to great lengths to ensure it remains connected whenever possible, including correctly handling error codes returned by the Pusher service (see http://pusher.com/docs/pusher_protocol#error-codes). 

In most cases where the connection fails or disconnects, Pusher will attempt to reconnect either immediately or after a configured delay (which defaults to 5s and can still be customised using the `reconnectDelay` property. 

In the case where Pusher returns a 4100 error code (over capacity), reconnection attempts will be attempted using a linear back-off delay. In all cases, Pusher will limit reconnection attempts to a maximum of three attempts before giving up.

There are two circumstances in which the client will not reconnect automatically:

  * The client disconnects with an error code in the 4000-4099 range, which generally indicates a client misconfiguration.
  * The client is not able to connect in the first place (i.e. it fails on it's first attempt), which normally indicates that there is no network connection or there is a server-side issue.

A new delegate method, `pusher:connection:didDisconnectWithError:willAttemptReconnect:` will be called when Pusher disconnects. The `willAttemptReconnect:` parameter will indicate to clients that `PTPusher` will automatically reconnect. If this is `NO`, clients should decide how they want to proceed (e.g. you may want to check network reachability and manually reconnect when reachability changes).

These changes should ensure that libPusher is much more reliable. You no longer need to explicitly disconnect and reconnect the client when going to the background or when the device is locked - in these situations the client will automatically reconnect when the app returns to the foreground or the device is unlocked.

The delegate methods `pusher:connection:didDisconnectWithError` and `pusher:connection:didDisconnect:` are now deprecated and will be removed in the next release.

Additionally, the `reconnectAutomatically` property of `PTPusher` has been deprecated. Setting this will not affect the automatic reconnection behaviour of `PTPusher`. If you need to take control of the auto-reconnect behaviour, a new delegate method is provided, `pusher:connectionWillAutomaticallyReconnect:afterDelay:`. Returning `NO` from this method will prevent the automatic reconnection attempt from happening. You will be responsible for manually reconnecting the client.

Pusher can be prevented from connecting *at any time* by returning `NO` from another new delegate method, `pusher:connectionWillConnect:`.

### Changes to presence channel members API

The API for accessing members of a channel has been brought in line with the JavaScript client.

Presence channels have a property `members`, which returns a instance of `PTPusherChannelMembers`, which is an unordered collection of members. Members can be retrieved by ID using the `memberWithID:` method. Members are represented by instances of the class `PTPusherChannelMember` rather than `NSDictionary` - see the headers for more information. There is also a property, `me`, which returns your own member object.

### Experimental ReactiveExtensions

This release contains some extensions that allow binding to events using ReactiveCocoa signals. These extensions are bundled as a separate library and if you're using CocoaPods, a sub-spec that is excluded from the default spec. These are still experimental so proceed with caution. You can add them to your project by adding `libPusher/ReactiveExtensions` to your `Podfile`. 

### Bug Fixes

* There have been numerous bug fixes around connection handling and Pusher should generally be more stable and remain connected in most cases where you have network connectivity. 
* libPusher now uses socket-native ping/pong and also sends client-side pings to keep the connection alive.
* Removed an assertion that would cause a crash if trying to send a client-send event when not connected.
* Calling `unsubscribe` on a channel while disconnected works as expected, with the channel being removed from the channels list and all bindings removed.

### Other enhancements and changes

* Bumped Pusher protocol to version 6.
* Switched to latest SocketRocket backend, improved threading issues
* Removed private headers from CocoaPod specification
* Removed `PTPusher` property, `reconnectAutomatically`
* Moved fatal protocol errors that disallow reconnection into a new `PTPusherFatalErrorDomain` error domain.
* Fixed 64bit warnings.
* Removed JSONKit support.
* Log warnings when calling deprecated delegate methods.

# 1.4 - October 2012

* This will be the final release to support iOS4.
* Support for ARMV6 has been removed.
* An authentication error delegate message will be called if your auth server does not return an NSDictionary. (#40)
* Generally improved error handling and notification for private channel authentication.
* Deprecated -[PTPusher unsubscribeFromChannel] in favour of -[PTPusherChannel unsubscribe]. (#43)
* Added some utilities to make unit testing against Pusher easier (such as a mock connection class).
* Reverted subtle change in behaviour introduced in 1.3, where delegate would be notified that the connection was open *before* the handshake event was received, meaning the socket ID would no longer be available at this point. (#47)
* Allow all bindings to be removed from the client/channel with a single method call. (#28)
* Fixed numerous bugs around SocketRocket callbacks and integration.
* Fixed various memory management issues.

# 1.3 - April 2012

* Switched to using NSJSONSerialization by default for JSON parsing ([see JSON notes](https://github.com/lukeredpath/libPusher/wiki/Adding-libPusher-to-your-project)).
* Bubble up any authorization connection errors to the Pusher delegate (#30)
* Ensure channel auth delegate methods are fired when authorization fails. (#30)
* Ensure connections can always be re-opened after a failure. (#32)
* Handle members added to a presence channel that have no user info. (#31)

# 1.2 - February 2012

* Changed backend socket library to [SocketRocket](http://github.com/square/SocketRocket)
* PTPusherEvent objects have a `timeReceived` property.
* Updated to the latest version of JSONKit.
* Re-added armv6 archicture for iOS 4.0 - 4.2 support.
* HTTP authorization for private/presence channels now accepts a HTTP 201 status as well as 200 (#23).
* Fixed triggering of client events (would previously send the channel name as the event name).
* Fixed retain cycle between PTPusher and PTPusherChannel.
* OSX framework is now called Pusher.framework.
* Project has been converted to use ARC (Automatic Reference Counting).
* All event binding methods return a PTPusherEventBinding object, which can be used to remove bindings (see "Removing Bindings" below).
* Channels should be removed from the cache when they are unsubscribed (#25).
* Subscribing to multiple private channels would fail as only the first channel would send the authorization request (#26).
* Wait for handshake and socket ID to be received before attempting to connect to channels as the socket ID is required for private/presence channel authorization.

# 1.1 - January 2012

* Added SSL support
* Fixed some runloop issues (#19, #16)
* Ensure channels are marked as unsubscribed on disconnect (#11)
* Ensure PTPusherEvent works with non-JSON data (#18)
* Include library and protocol version in the request.
* Updates for the latest versions of the Pusher protocol.
* Fixed some low-level bugs in the ZTWebSocket library.
* Handle Pusher ping/pong and error events.

# 1.0 - August 2011

* Re-architected the core API to bring it in line with the Javascript API.
* Support multiple channels over a single connection.
* Added support for private and presence channels.
* Added block-support for event callbacks.
* Extracted the wrapper for the Pusher REST API into a standalone component.
* Dropped support for iOS 3.0
