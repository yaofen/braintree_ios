#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowRequest.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#endif

/// We likely can remove this abstract class and instead pass a generic in to the super class or an NSObject
@implementation BTPaymentFlowRequest

@end
