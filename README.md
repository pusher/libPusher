# libPusher, an Objective-C client for Pusher

[Pusher](http://pusherapp.com/) by [New Bamboo](http://new-bamboo.co.uk) is a hosted service that sits between your web application and the browser that lets you deliver events in real-time using HTML5 WebSockets (using Flash as a fallback).

This project was borne out of the idea that a web browser doesn't have to be the only client that receives your web app's real-time notifications. Why couldn't your iPhone, iPad or Mac OSX app receive real-time notifications either?

Apple provides its own push notification service which is great for getting alert-type notifications to your app's users whether or not they are using the app, but for real-time updates to data whilst they are using your app, hooking into your web app's existing event-dispatch mechanism is far less hassle (and is great if you want to be able to interact with other web services that might not have access to the APNS).

## Installation instructions

The libPusher Xcode project contains a static library target that lets you compile a static library for use in your own 
applications. There are several ways of getting this static library into your application: one convenient way would be to import the libPusher Xcode project into your own Xcode project as a cross-project reference. This will ensure the latest static library gets built whenever your app is built and means you can refer to Git clone of the project and keep up-to-date with the latest changes.

For more detailed instructions on adding a static library via an Xcode cross-project reference, please refer to [this guide](http://www.amateurinmotion.com/articles/2009/02/08/creating-a-static-library-for-iphone.html), starting from the section "Linking against static library". You will need to remember to update your project's header search path so it can find the header files if you haven't added them directly to your project.

Alternatively, you can simply copy the relevant files (all the files in the Library folder, plus all of the files in Vendor) into your project although you will need to take care of updating the files with changes yourself.

In addition to the above instructions, you will need to add `-all_load` to your build settings under "Other linker flags", to ensure the categories defined by the library are loaded.

### Building notes

The project includes the Zimt library as a Git submodule; you'll need to init your Git submodules before you are able to build. 

    $ git submodule update --init --recursive
    
To build and run the sample app, you'll need to create a Constants.h file containing your Pusher API key and secret; see the sample application app delegate for instructions.

## Getting started using simple event monitors

To start monitoring events from a channel, you need to create a new `PTPusher` instance. You can then choose to either add specific event listeners that use the Cocoa target/selector idiom for responding to events, or you can subscribe to notifcations using `NSNotificationCenter`. Here is an example of responding to an event using an event listener:

    PTPusher *pusher = [[PTPusher alloc] initWithKey:@"YOUR_API_KEY" channel:@"CHANNEL_NAME"];
    [pusher addEventListener:@"event_name" target:self selector:@selector(handleEvent:)];
    
And then in your event callback:

    - (void)handleEvent:(PTPusherEvent *)event;
    {
      // just log the event
      NSLog(@"Received event %@ with data %@", event.name, event.data);
    }
    
To use the notification mechanism, simply register an observer for the `PTPusherEventReceivedNotification` notification.

    [[NSNotificationCenter] defaultCenter] addObserver:self 
        selector:@selector(handleEvent:) name:PTPusherEventReceivedNotification object:nil]
        
Like any Cocoa notification, the notification callback will be passed an `NSNotifcation` instance. The `PTPusherEvent` object can be obtained using the notification's `object` property:

    - (void)handleEvent:(NSNotification *)note;
    {
      PTPusherEvent *event = note.object;
      NSLog(@"I got an event %@ from channel %@", note.name, note.channel);
    }
    
For more information, read [this introductory blog post](http://lukeredpath.co.uk/blog/pushing-events-to-your-iphone-using-websockets-and-pusher.html).

## Using PTPusherChannel for event triggering and delegate-based event handling 

`PTPusherChannel` offers a higher level interface for dealing with events on a single channel. By creating an instance of `PTPusherChannel` and assigning a delegate, you can respond to events that arrive on just that channel and also trigger new events (using the Pusher REST API).

To simplify the API for creating new channel instances, `PTPusher` provides a shared factory method; to use this you will need to configure your application-wide API key, secret and application ID:

    - (void)applicationDidFinishLaunching:(UIApplication *)application 
    {    
      [PTPusher setKey:@"your_api_key"];
      [PTPusher setSecret:@"your_api_secret"];
      [PTPusher setAppID:@"your_app_id"];
      ...
    }
    
Once this has been configured, creating a new channel is easy:

    self.eventsChannel = [PTPusher channel:@"events"];
    self.eventsChannel.delegate = self; // implement PTPusherChannelDelegate
    
Its important to note that the `channel` factory method returns an auto-released instance, so you will need to ensure you retain it. If you want a non-autoreleased instance, you can alternatively call the `newChannel:` method instead.

Once you have created a channel and assigned a delegate, new events on that channel will trigger the delegate method `channel:didReceiveEvent`, e.g.:

    - (void)channel:(PTPusherChannel *)channel didReceiveEvent:(PTPusherEvent *)event;
    {
      if(channel == self.eventsChannel) { // if you're monitoring multiple channels
        // do something with event
      }
    }

Instances of `PTPusherChannel` can also be used to trigger new events using the Pusher REST API. Triggering an event is easy; all you need to specify is the event name and the payload, which can be a string or any Objective-C plist object that can be serialized as JSON (e.g. NSDictionary or NSArray):

    - (IBAction)triggerAction:(id)sender
    {
      NSDictionary *payload = [NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"];
      [self.eventsChannel triggerEvent:@"new-event" data:payload];
    }
    
For details of other `PTPusherChannel` delegate methods, take a look at PTPusherChannelDelegate.h and the sample project.

## Other options

### Delegate object

PTPusher has a delegate property which can be used to notify the owner of the `PTPusher` instance of certain events in the pusher's life-cycle (such as disconnections etc.). Your delegate must conform to the `PTPusherDelegate` protocol, although all of the delegate methods are optional. To set the delegate:

    // where self conforms to PTPusherDelegate
    pusher = [[PTPusher alloc] initWithKey:@"YOUR_API_KEY" channel:@"CHANNEL_NAME"];
    pusher.delegate = self;
    
For an overview of the available delegate methods, see PTPusherDelegate.h.

### Reconnections

By default, `PTPusher` will not attempt to reconnect if the connection is broken. You can turn reconnection support on using the `reconnect` property:

    pusher.reconnect = YES;
    
Currently, reconnect support is fairly basic; there is no maximum retry limit and the retry delay is hard-coded to 5 seconds.

## TODO

* Support for Presence
* Block-based API for iOS4/OSX 10.6 and above

## Credits

PusherTouch uses the [ZTWebSocket](http://github.com/openresearch/zimt) library by [OpenResearch](http://github.com/openresearch), without which I probably wouldn't have got anywhere.
[Pusher](http://pusherapp.com) is a [New Bamboo](http://new-bamboo.co.uk) product.

## License

All code is licensed under the MIT license. See the LICENSE file for more details.
