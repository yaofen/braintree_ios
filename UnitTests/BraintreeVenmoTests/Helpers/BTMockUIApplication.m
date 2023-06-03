@import OCMock;

#import "BTMockUIApplication.h"

@implementation BTMockUIApplication

- (void)stubCanOpenURLWith:(BOOL)canOpenURL {
    _mock = OCMClassMock(UIApplication.sharedApplication.class);
    // OCMStub(_mock.URL).andReturn(url);
    OCMStub([_mock canOpenURL:[OCMArg any]]).andReturn(canOpenURL);
}

@end
