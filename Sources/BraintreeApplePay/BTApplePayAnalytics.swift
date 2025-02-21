import Foundation

// NEXT_MAJOR_VERSION: Move this class to an enum once the entire SDK is in Swift
class BTApplePayAnalytics {

    // MARK: - Payment Request Events

    static let paymentRequestStarted = "apple-pay:payment-request:started"
    static let paymentRequestFailed = "apple-pay:payment-request:failed"
    static let paymentRequestSucceeded = "apple-pay:payment-request:succeeded"

    // MARK: - Tokenize Request Events

    static let tokenizeStarted = "apple-pay:tokenize:started"
    static let tokenizeFailed = "apple-pay:tokenize:failed"
    static let tokenizeSucceeded = "apple-pay:tokenize:succeeded"
}
