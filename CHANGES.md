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
