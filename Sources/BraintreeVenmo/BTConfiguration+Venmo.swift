import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

extension BTConfiguration {

    ///  :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Indicates whether Venmo is enabled for the merchant account.
    @objc public var isVenmoEnabled: Bool {
        venmoAccessToken != nil
    }

    /// Returns the Access Token used by the Venmo app to tokenize on behalf of the merchant.
    var venmoAccessToken: String? {
        json?["payWithVenmo"]["accessToken"].asString()
    }

    /// Returns the Venmo merchant ID used by the Venmo app to authorize payment.
    var venmoMerchantID: String? {
        json?["payWithVenmo"]["merchantId"].asString()
    }

    /// Returns the Venmo environment used to handle this payment.
    var venmoEnvironment: String? {
        json?["payWithVenmo"]["environment"].asString()
    }
}
