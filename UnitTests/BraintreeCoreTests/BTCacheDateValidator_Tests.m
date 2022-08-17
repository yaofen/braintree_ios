#import <XCTest/XCTest.h>
@import BraintreeCoreSwift;

@interface BTCacheDateValidator_Tests : XCTestCase

@end

@implementation BTCacheDateValidator_Tests

- (void)testTimeToLiveMinutes_defaultsTo5 {
    BTCacheDateValidator *cacheDateValidator = [[BTCacheDateValidator alloc] init];
    XCTAssertEqual(5, cacheDateValidator.timeToLiveMinutes);
}

@end
