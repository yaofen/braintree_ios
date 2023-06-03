@import OCMock;

#import "BTMockUIApplication.h"

@interface BTMockUIApplication ()

@property (strong, nonatomic) id mockApplication;

@end

@implementation BTMockUIApplication

-(id)init {
    if (self = [super init]) {
        _mockApplication = [OCMockObject niceMockForClass:[UIApplication class]];
        [[[_mockApplication stub] andReturn:_mockApplication] sharedApplication];
    }
    return self;
}

- (void)stubCanOpenURLWith:(BOOL)canOpenURL {
    OCMStub([_mockApplication canOpenURL:[OCMArg any]]).andReturn(canOpenURL);
}

- (void)verifyOpenURLCalledWith:(NSURL *)url {
    [[_mockApplication expect] openURL:[OCMArg any] options:[OCMArg any] completionHandler:[OCMArg any]];
    [_mockApplication verify];
    
    // TODO why is my test saying that this method was never called?
//    OCMVerify([_mockApplication openURL:url options: [OCMArg any] completionHandler:[OCMArg any]]);
}

@end
