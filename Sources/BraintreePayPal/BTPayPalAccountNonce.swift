import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains information about a PayPal payment method
/// This would now need to conform to BTPaymentFlowResult instead of BTPaymentMethodNonce since we can only have 1 superclass
/// This would require us to duplicate BTPaymentMethodNonce logic... which defeats the purpose of BTPaymentMethodNonce
/// Additionally BTPaymentFlowResult is just an empty class that conforms to NSObject so is significantly less useful
/// This seems to break the pattern that we have been moving to over the years - it seems like a better approach to bring PaymentFlow
/// and 3DS into the patterns that we use currently as they are both outdated (as an example BTLocalPaymentResult and
/// BTThreeDSecureResult is actually a nonce under the hood)
@objcMembers public class BTPayPalAccountNonce: BTPaymentMethodNonce {
    
    /// Payer's email address.
    public let email: String?
    
    /// Payer's first name.
    public let firstName: String?
    
    /// Payer's last name.
    public let lastName: String?
    
    /// Payer's phone number.
    public let phone: String?
    
    /// The billing address.
    public let billingAddress: BTPostalAddress?
    
    /// The shipping address.
    public let shippingAddress: BTPostalAddress?
    
    /// Client metadata id associated with this transaction.
    public let clientMetadataID: String?
    
    /// Optional. Payer id associated with this transaction.
    /// Will be provided for Vault and Checkout.
    public let payerID: String?
    
    /// Optional. Credit financing details if the customer pays with PayPal Credit.
    /// Will be provided for Vault and Checkout.
    public let creditFinancing: BTPayPalCreditFinancing?
    
    init?(json: BTJSON) {
        guard let nonce = json["nonce"].asString() else { return nil }
        
        let details = json["details"]
        let payerInfo = details["payerInfo"]

        self.email = payerInfo["email"].asString() ?? details["email"].asString()        
        self.firstName = payerInfo["firstName"].asString()  
        self.lastName = payerInfo["lastName"].asString()
        self.phone = payerInfo["phone"].asString()
        self.billingAddress = payerInfo["billingAddress"].asAddress()
        self.shippingAddress = payerInfo["shippingAddress"].asAddress() ?? payerInfo["accountAddress"].asAddress()
        self.clientMetadataID = payerInfo["correlationId"].asString()
        self.payerID = payerInfo["payerId"].asString()
        self.creditFinancing = details["creditFinancingOffered"].asPayPalCreditFinancing()
        super.init(nonce: nonce, type: "PayPal", isDefault: json["default"].isTrue)
    }
}
