import Foundation

@objcMembers public class BTClientTokenSwift: NSObject, NSCoding, NSCopying {

    let version: String = "version"

    /// The client token as a BTJSON object
    public let json: BTJSON?

    /// The extracted authorization fingerprint
    public let authorizationFingerprint: String?

    /// The extracted configURL
    public let configURL: URL?

    /// The original string used to initialize this instance
    public let originalValue: String?

    /// Initialize a client token with a client token string generated by a Braintree Server Library.
    @objc(initWithClientToken:error:)
    public init?(clientToken: String?, error: NSError?) {
        guard BTClientTokenSwift.validateClientToken(error: error) else {
            return nil
        }

        // Client token must be decoded first because the other values are retrieved from it
        self.json = BTClientTokenSwift.decodeClientToken(clientToken, error: error)
        self.authorizationFingerprint = json?["authorizationFingerprint"].asString()
        self.configURL = json?["configUrl"].asURL()
        self.originalValue = clientToken

    }

    static private func decodeClientToken(_ rawClientToken: String?, error: NSError?) -> BTJSON {
        // TODO: add functionality
        BTJSON()
    }

    static private func validateClientToken(error: NSError?) -> Bool {
        // TODO: add functionality
        return false
    }


    // MARK: - NSCoding conformance

    public func encode(with coder: NSCoder) {
        coder.encode(originalValue, forKey: "originalValue")
    }

    public required convenience init?(coder: NSCoder) {
        self.init(
            clientToken: coder.decodeObject(forKey: "originalValue") as? String,
            error: nil
        )
    }

    // MARK: - NSCopying conformance

    @objc(copyWithZone:)
    public func copy(with zone: NSZone? = nil) -> Any {
        // TODO: is there a better way to do this
        BTClientTokenSwift(clientToken: self.originalValue, error: nil) as Any
    }
}
