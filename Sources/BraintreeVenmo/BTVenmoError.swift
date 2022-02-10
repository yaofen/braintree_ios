import Foundation

///  Error details associated with American Express.
enum BTVenmoError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// Venmo is disabled in configuration
    case disabled
    
    /// App is not installed on device
    case appNotAvailable
    
    /// Bundle display name must be present
    case bundleDisplayNameMissing
    
    /// UIApplication failed to switch to Venmo app
    case appSwitchFailed
    
    /// Return URL was invalid
    case invalidReturnURL
    
    /// Braintree SDK is integrated incorrectly
    case integration
    
    /// Request URL was invalid, configuration may be missing required values
    case invalidRequestURL

    static var errorDomain: String {
        "com.braintreepayments.BTVenmoErrorDomain"
    }
    
    var errorCode: Int {
        switch self {
        case .unknown:
            return 0
            switch self {
            case .unknown:
                return 0
            case .disabled:
                return 1
            case .appNotAvailable:
                return 2
            case .bundleDisplayNameMissing:
                return 3
            case .appSwitchFailed:
                return 4
            case .invalidReturnURL:
                return 5
            case .integration:
                return 6
            case .invalidRequestURL:
                return 7
            }
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occured. Please contact support."

        case .disabled:
            return "Venmo is not enabled for this merchant account."
        case .appNotAvailable:
            return "The Venmo app is not installed on this device, or it is not configured or available for app switch."
        case .bundleDisplayNameMissing:
            return "CFBundleDisplayName must be non-nil. Please set 'Bundle display name' in your Info.plist."
        case .appSwitchFailed:
            return "UIApplication failed to perform app switch to Venmo."
        case .invalidReturnURL:
            return "Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support."
        case .integration:
            return "BTVenmoDriver failed because BTVenmoRequest is nil."
        case .invalidRequestURL:
            return "Failed to create Venmo app switch request URL."
        }
    }
}
