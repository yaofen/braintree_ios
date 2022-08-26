import Foundation

///  Error codes associated with a client token.
enum BTClientTokenError: Error, CustomNSError, LocalizedError {

    /// 0. A field was invalid
    case invalidJSONValue(String)

    /// 2. Invalid client token format
    case invalidFormat(String)

    /// 4. Unsupported client token version
    case unsupportedVersion
    
    /// 5. Failed decoding from Base64 or UTF8
    case failedDecoding(String)

    static var errorDomain: String {
        "com.braintreepayments.BTClientTokenErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .invalidJSONValue:
            return 0
        case .invalidFormat:
            return 1
        case .unsupportedVersion:
            return 2
        case .failedDecoding:
            return 3
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidJSONValue(let key):
            return "Invalid value in client token. Please ensure your server is generating a valid Braintree ClientToken. Value for key \"\(key)\" was not present or invalid."
        case .invalidFormat(let description):
            return "Invalid client token format. Please ensure your server is generating a valid Braintree ClientToken. \(description)"
        case .unsupportedVersion:
            return "Unsupported client token version. Please ensure your server is generating a valid Braintree ClientToken with a server-side SDK that is compatible with this version of Braintree iOS."
        case .failedDecoding(let description):
            return "Failed to decode client token. \(description)"
        }
    }
}
