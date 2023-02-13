#import "BTPaymentFlowClient_Internal.h"

#if __has_include(<Braintree/BraintreePaymentFlow.h>) // CocoaPods
#import <Braintree/BTPaymentFlowClient+LocalPayment.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreePaymentFlow/BTPaymentFlowClient+LocalPayment.h>

#else // Carthage
#import <BraintreePaymentFlow/BTPaymentFlowClient+LocalPayment.h>

#endif

/// This should handle the LPM specific logic for the strongly typed start method
@implementation BTPaymentFlowClient (LocalPayment)

@end
