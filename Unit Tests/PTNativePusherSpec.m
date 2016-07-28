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
@property (nonatomic, strong) NSMutableSet* subscriptions;
- (void)nativePusher:(PTNativePusher *)nativePusher didRegisterForPushNotificationsWithClientId:(NSString *)clientId;
- (void)nativePusher:(PTNativePusher *)nativePusher didSubscribeToInterest:(NSString *)interestName;
- (void)nativePusher:(PTNativePusher *)nativePusher didUnsubscribeFromInterest:(NSString *)interestName;
@end

@implementation TestPusherDelegate
- (id) init {
  [self setClientId:nil];
  [self setSubscriptions:[[NSMutableSet alloc] init]];
  return self;
}

- (void)nativePusher:(PTNativePusher *)nativePusher didRegisterForPushNotificationsWithClientId:(NSString *)clientId {
  [self setClientId:clientId];
}

- (void)nativePusher:(PTNativePusher *)nativePusher didSubscribeToInterest:(NSString *)interestName {
  [[self subscriptions] addObject:interestName];
}

- (void)nativePusher:(PTNativePusher *)nativePusher didUnsubscribeFromInterest:(NSString *)interestName {
  [[self subscriptions] removeObject:interestName];
}
@end


SPEC_BEGIN(PTNativePusherSpec)

describe(@"PTNativePusherSpec", ^{
  __block TestPusherDelegate *testDelegate;
  __block PTPusher *pusher;
  
  beforeEach(^{
    testDelegate = [TestPusherDelegate new];
    pusher = [PTPusher pusherWithKey:@"MY_APP_KEY" delegate:testDelegate];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
      return [request.URL isEqual:[NSURL URLWithString:@"https://nativepushclient-cluster1.pusher.com/client_api/v1/clients"]] && [[request HTTPMethod] isEqualToString:@"POST"];  // TODO test app_key, platform_type, token
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
      return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:@{@"id": @"your_new_client_id"} options:0 error:nil]
                                        statusCode:201
                                           headers:nil];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
      return [request.URL isEqual:[NSURL URLWithString:@"https://nativepushclient-cluster1.pusher.com/client_api/v1/clients/your_new_client_id/interests/donuts"]] && [[request HTTPMethod] isEqualToString:@"POST"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
      return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:204 headers:nil];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
      return [request.URL isEqual:[NSURL URLWithString:@"https://nativepushclient-cluster1.pusher.com/client_api/v1/clients/your_new_client_id/interests/donuts"]] && [[request HTTPMethod] isEqualToString:@"DELETE"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
      return [OHHTTPStubsResponse responseWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding] statusCode:204 headers:nil];
    }];
  });
  
  afterEach(^{
    [OHHTTPStubs removeAllStubs];
  });
  
  it(@"should get a client id after register is called", ^{
    [[pusher nativePusher] registerWithDeviceToken:[@"SOME_DEVICE_TOKEN" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[expectFutureValue([testDelegate clientId]) shouldEventually] equal:@"your_new_client_id"];
  });
  
  it(@"should subscribe to an interest when told to", ^{

    [[pusher nativePusher] subscribe:@"donuts"];
    
    [[pusher nativePusher] registerWithDeviceToken:[@"SOME_DEVICE_TOKEN" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[expectFutureValue(@([[testDelegate subscriptions] containsObject:@"donuts"])) shouldEventually] equal:@true];
  });
  
  it(@"should unsubscribe from an interest when told to", ^{
    
    [[pusher nativePusher] subscribe:@"donuts"];
    
    [[pusher nativePusher] registerWithDeviceToken:[@"SOME_DEVICE_TOKEN" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[expectFutureValue(@([[testDelegate subscriptions] containsObject:@"donuts"])) shouldEventually] equal:@true];
    
    [[pusher nativePusher] unsubscribe:@"donuts"];
    
    [[expectFutureValue(@([[testDelegate subscriptions] containsObject:@"donuts"])) shouldEventually] equal:@false];
  });
});

SPEC_END