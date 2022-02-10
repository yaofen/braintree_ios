import Foundation

@objcMembers public class BTVenmoRequest {
    
    public enum BTPaymentMethodUsage: Int {
        
        /// The Venmo payment will be authorized for future payments and can be vaulted.
        case multiUse
        
        /// The Venmo payment will be authorized for a one-time payment and cannot be vaulted.
        case singleUse
    }
    
    /// The Venmo profile ID to be used during payment authorization. Customers will see the business name and logo associated with this Venmo profile, and it may show up in the Venmo app as a "Connected Merchant". Venmo profile IDs can be found in the Braintree Control Panel. Leaving this `nil` will use the default Venmo profile.
    var profileID: String?

    /// Whether to automatically vault the Venmo account on the client. For client-side vaulting, you must initialize BTAPIClient with a client token that was created with a customer ID. Also, `paymentMethodUsage` on the BTVenmoRequest must be set to `.multiUse`.
    /// If this property is set to false, you can still vault the Venmo account on your server, provided that `paymentMethodUsage` is not set to `.singleUse`.
    /// Defaults to false.
    var vault: Bool = false
    
    /// If set to `.multiUse`, the Venmo payment will be authorized for future payments and can be vaulted.
    /// If set to `.singleUse`, the Venmo payment will be authorized for a one-time payment and cannot be vaulted.
    var paymentMethodUsage: BTPaymentMethodUsage?

    /// Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
    var displayName: String?
    
    public init(paymentMethodUsage: BTPaymentMethodUsage) {
        self.paymentMethodUsage = paymentMethodUsage
    }
    
    var paymentMethodUsageAsString: String? {
        switch(self.paymentMethodUsage) {
        case .multiUse:
            return "MULTI_USE"
        case .singleUse:
            return "SINGLE_USE"
        default:
            return nil
        }
    }
}
