#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowResult.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>
#endif

/// We likely can remove this abstract class and instead pass a generic in to the super class or an NSObject or a BTPaymentMethodNonce subclass
@implementation BTPaymentFlowResult

@end
