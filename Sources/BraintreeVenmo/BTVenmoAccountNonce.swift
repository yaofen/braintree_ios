import Foundation

@objcMembers public class BTVenmoAccountNonce: BTPaymentMethodNonce {
    
    /**
     :nodoc:
     The email associated with the Venmo account
    */
    var email: String?

    /**
     :nodoc:
     The external ID associated with the Venmo account
    */
    var externalId: String?

    /**
     :nodoc:
     The first name associated with the Venmo account
    */
    var firstName: String?

    /**
     :nodoc:
     The last name associated with the Venmo account
    */
    var lastName: String?

    /**
     :nodoc:
     The phone number associated with the Venmo account
    */
    var phoneNumber: String?

    /**
     The username associated with the Venmo account
    */
    var username: String?
    
    convenience init?(paymentContextJSON: BTJSON) {
        self.init(paymentMethodNonce: paymentContextJSON["data"]["node"]["paymentMethodId"].asString() ?? "", username: paymentContextJSON["data"]["node"]["userName"].asString() ?? "", isDefault: false)
        
        if (paymentContextJSON["data"]["node"]["payerInfo"].asString() != nil) {
            self.email = paymentContextJSON["data"]["node"]["payerInfo"]["email"].asString()
            self.externalId = paymentContextJSON["data"]["node"]["payerInfo"]["externalId"].asString()
            self.firstName = paymentContextJSON["data"]["node"]["payerInfo"]["firstName"].asString()
            self.lastName = paymentContextJSON["data"]["node"]["payerInfo"]["lastName"].asString()
            self.phoneNumber = paymentContextJSON["data"]["node"]["payerInfo"]["phoneNumber"].asString()
        }
    }
    
    convenience init?(venmoAccountJSON: BTJSON) {
        self.init(paymentMethodNonce: venmoAccountJSON["nonce"].asString() ?? "", username: venmoAccountJSON["details"]["username"].asString() ?? "", isDefault: venmoAccountJSON["default"].isTrue)
    }
    
    init?(paymentMethodNonce nonce: String, username: String, isDefault: Bool) {
        super.init(nonce: nonce, type: "Venmo", isDefault: isDefault)
        self.username = username
    }
}
