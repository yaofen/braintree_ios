#if SWIFT_PACKAGE
#import "BTVenmoAccountNonce.h"
#else
#import <BraintreeVenmo/BTVenmoAccountNonce.h>
#endif

@interface BTVenmoAccountNonce ()

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                  username:(NSString *)username
                                 isDefault:(BOOL)isDefault;

+ (instancetype)venmoAccountWithJSON:(BTJSON *)venmoAccountJSON;

@end
