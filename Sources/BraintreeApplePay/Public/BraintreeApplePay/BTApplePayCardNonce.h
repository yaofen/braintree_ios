#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>
#elif SWIFT_PACKAGE
@import BraintreeCore;
#else
@class BTJSON;
@class BTBinData;
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about a tokenized Apple Pay card.
 */
@interface BTApplePayCardNonce : NSObject

/**
 The payment method nonce.
 */
@property (nonatomic, readonly, strong) NSString * _Nonnull nonce;

/**
 The string identifying the type of the payment method.
 */
@property (nonatomic, readonly, strong) NSString * _Nullable type;

/**
 The boolean indicating whether this is a default payment method.
 */
@property (nonatomic, readwrite, assign) BOOL isDefault;

/**
 The BIN data for the card number associated with this nonce.
 */
@property (nonatomic, readonly, strong) BTBinData *binData;

/**
 Used to initialize a `BTApplePayCardNonce` with parameters.
 */
- (nullable instancetype)initWithJSON:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END
