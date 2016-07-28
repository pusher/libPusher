//
//  PTNativePusherSpec.m
//  libPusher
//
//  Created by James Fisher on 28/07/2016.
//
//

#import "SpecHelper.h"
#import "OHHTTPStubs.h"


@interface TestPusherDelegate : NSObject <PTPusherDelegate>
@property (nonatomic, strong) NSString* clientId;
- (void)nativePusher:(PTNativePusher *)nativePusher didRegisterForPushNotificationsWithClientId:(NSString *)clientId;
@end

@implementation TestPusherDelegate
- (void)nativePusher:(PTNativePusher *)nativePusher didRegisterForPushNotificationsWithClientId:(NSString *)clientId {
  [self setClientId:clientId];
}
@end


SPEC_BEGIN(PTNativePusherSpec)

describe(@"PTNativePusherSpec", ^{
  __block TestPusherDelegate *testDelegate;
  __block PTPusher *pusher;
  
  beforeEach(^{
    testDelegate = [TestPusherDelegate new];
    pusher = [PTPusher pusherWithKey:@"MY_APP_KEY" delegate:testDelegate];
  });
  
  it(@"should get a client id after register is called", ^{
    
    NSURL *clientsURL = [NSURL URLWithString:@"https://nativepushclient-cluster1.pusher.com/client_api/v1/clients"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
      return [request.URL isEqual:clientsURL] && [[request HTTPMethod] isEqualToString:@"POST"];  // TODO test app_key, platform_type, token
      
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
      return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{@"id": @"your_new_client_id"} options:0 error:nil]
                                        statusCode:201
                                           headers:nil];
    }];

    [[pusher nativePusher] registerWithDeviceToken:[@"SOME_DEVICE_TOKEN" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[expectFutureValue([testDelegate clientId]) shouldEventually] equal:@"your_new_client_id"];
  });
});

SPEC_END