# libPusher, an Objective-C client for Pusher

[Pusher](http://pusherapp.com/) by [New Bamboo](http://new-bamboo.co.uk) is a hosted service that sits between your web application and the browser that lets you deliver events in real-time using HTML5 WebSockets (using Flash as a fallback).

This project was borne out of the idea that a web browser doesn't have to be the only client that receives your web app's real-time notifications. Why couldn't your iPhone, iPad or Mac OSX app receive real-time notifications either?

Apple provides its own push notification service which is great for getting alert-type notifications to your app's users whether or not they are using the app, but for real-time updates to data whilst they are using your app, hooking into your web app's existing event-dispatch mechanism is far less hassle (and is great if you want to be able to interact with other web services that might not have access to the APNS).

## Installation instructions

The libPusher Xcode project contains a static library target that lets you compile a static library for use in your own applications. There are several ways of getting this static library into your application: one convenient way would be to import the libPusher Xcode project into your own Xcode project as a cross-project reference. This will ensure the latest static library gets built whenever your app is built and means you can refer to Git clone of the project and keep up-to-date with the latest changes.

For more detailed instructions on adding a static library via an Xcode cross-project reference, please refer to [this guide](http://www.amateurinmotion.com/articles/2009/02/08/creating-a-static-library-for-iphone.html). 

Alternatively, you can simply copy the relevant files (all the files in the Library folder, plus all of the files in Vendor) into your project although you will need to take care of updating the files with changes yourself.

In addition to the above instructions, you will need to add `-all_load` to your build settings under "Other linker flags".

## Getting started

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

## Credits

PusherTouch uses the [ZTWebSocket](http://github.com/openresearch/zimt) library by [OpenResearch](http://github.com/openresearch), without which I probably wouldn't have got anywhere.

## License

All code is licensed under the MIT license. See the LICENSE file for more details.
