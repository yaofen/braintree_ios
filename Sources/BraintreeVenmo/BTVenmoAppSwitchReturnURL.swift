import Foundation

@objcMembers class BTVenmoAppSwitchReturnURL {
   
    let BTVenmoAppSwitchReturnURLErrorDomain = "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain"
    
    enum BTVenmoAppSwitchReturnURLState: Int {
        case succeededWithPaymentContext
        case succeeded
        case failed
        case canceled
        case unknown
    }
    
    var state: BTVenmoAppSwitchReturnURLState
    var paymentContextID: String?
    var nonce: String?
    var username: String?
    var error: Error?
    
    func isValidURL(url: URL) -> Bool {
        return url.host == "x-callback-url" && url.path.hasPrefix("/vzero/auth/venmo/")
    }
    
    init(url: URL) {
        let parameters = BTURLUtils.queryParameters(for: url)
        if (url.path == "/vzero/auth/venmo/success") {
            if (parameters["resource_id"] != nil) {
                self.state = .succeededWithPaymentContext
                self.paymentContextID = parameters["resource_id"]
            } else {
                self.state = .succeeded
                self.nonce = parameters["paymentMethodNonce"]
                self.username = parameters["username"]
            }
        } else if (url.path == "/vzero/auth/venmo/error") {
            self.state = .failed
            // TODO: customize error
            self.error = BTVenmoError.appSwitchFailed
        } else if (url.path == "/vzero/auth/venmo/cancel") {
            self.state = .canceled
        } else {
            self.state = .unknown
        }
    }
}
