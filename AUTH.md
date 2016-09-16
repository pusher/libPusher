## Channel authorization

libPusher ships with built-in support for server-based channel authorization but provides the flexibility to authorize channel access in whatever way makes sense for your app using a delegate protocol.

When you subscribe to a channel that requires authorization (a private or presence channel), `PTPusher` will ask its `channelAuthorizationDelegate` to perform the authorization. More details on how this works can be found below.

### Server-based authorization

The standard way to authorize channel access is to ask a central server if a user has access to the channel by making an HTTP POST request. If successful, a response containing the authorization data needed to subscribe to the channel is returned. More details can be found [in the Pusher documentation](https://pusher.com/docs/authenticating_users).

libPusher ships with an implementation of `PTPusherChannelAuthorizationDelegate` -  `PTPusherChannelServerBasedAuthorization` - that uses `NSURLSession` to POST the channel name and current connection's socket ID to pre-configured URL and passes back the response body `PTPusher` so it can subscribe to the channel.

In order to support backwards compatibility, it is not currently necessary to initialize an instance of `PTPusherChannelServerBasedAuthorization` and assign it to the `channelauthorizationDelegate` property of your `PTPusher` object. Instead, you simply need to set the `authorizationURL` property, as in previous versions of libPusher.

```objc
pusher.authorizationURL = [NSURL URLWithString:@"http://www.yourserver.com/authorize"];
```

Unlike web-based clients, you cannot rely on cookies and sessions to authenticate users when making these channel authorization requests; instead, you must use some other form of authentication such as tokens or basic authentication. To do this, you can implement the delegate method `pusher:willAuthorizeChannel:withAuthOperation:` and modify the request before it is sent, e.g.:

```objc
- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withAuthOperation:(PTPusherChannelAuthorizationOperation *)operation
{
  [operation.mutableURLRequest setValue:@"some-authentication-token" forHTTPHeaderField:@"X-MyCustom-AuthTokenHeader"];
}
```

Note: it is likely that the `authorizationURL` API will be removed in a future version of libPusher, meaning you will need to configure the server-auth object and assign it as the auth delegate manually.

### Custom authorization

In order to perform custom authorization, you need to assign the `channelAuthorizationDelegate` and implement the `PTPusherChannelAuthorizationDelegate` protocol, which currently contains a single method. The following example uses the `AFNetworking` library to perform server-based authorization:

```objc
- (BOOL)applicationDidFinishLaunching:(UIApplication *)application
{
  ...
  self.pusherClient.channelAuthorizationDelegate = self;
}

- (void)pusherChannel:(PTPusherChannel *)channel requiresAuthorizationForSocketID:(NSString *)socketID completionHandler:(void(^)(BOOL isAuthorized, NSDictionary *authData, NSError *error))completionHandler
{
  NSDictionary *authParameters = :@{@"socket_id": socketID, @"channel_name": channel.name};

  [[MyHTTPClient sharedClient] postPath:@"/pusher/auth" parameters:authParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
      completionHandler(YES, responseObject, nil);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    completionHandler(NO, nil, error);
  }];
}
```
