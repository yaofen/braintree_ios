import Foundation
import BraintreeCore

@objcMembers class BTVenmoAppSwitchRequestURL {
    
    static let kXCallbackTemplate = "scheme://x-callback-url/path"
    
    static let kVenmoScheme = "com.venmo.touch.v2"
    
    class func baseAppSwitchURL() -> URL? {
        return appSwitchBaseURLComponents()?.url
    }
    
    class func appSwitchURL(merchantID: String, accessToken: String, returnURLScheme scheme: String, bundleDisplayName bundleName: String, environment: String, paymentContextID: String?, metadata: BTClientMetadata) -> URL? {
        let successReturnURL = returnURL(scheme: scheme, result: "success")
        let errorReturnURL = returnURL(scheme: scheme, result: "error")
        let cancelReturnURL = returnURL(scheme: scheme, result: "cancel")
        
//        if (successReturnURL == nil || errorReturnURL == nil || cancelReturnURL == nil || accessToken == nil || metadata == nil || scheme == nil || bundleName == nil || environment == nil || merchantID == nil) {
//            return nil
//        }
//
        let braintreeData = ["_meta": [
            "version": "5.6.3",
            "sessionId": metadata.sessionID,
            "integration": metadata.integrationString,
            "platform": "ios"
            ]
        ]
        
        do {
            let serializedBraintreeData = try JSONSerialization.data(withJSONObject: braintreeData, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let base64EncodedBraintreeData = serializedBraintreeData.base64EncodedData(options: Foundation.Data.Base64EncodingOptions.endLineWithCarriageReturn)
            
            var appSwitchParameters =  ["x-success": successReturnURL as Any,
                                        "x-error": errorReturnURL as Any,
                                        "x-cancel": cancelReturnURL as Any,
                                    "x-source": bundleName,
                                    "braintree_merchant_id": merchantID,
                                    "braintree_access_token": accessToken,
                                    "braintree_environment": environment,
                                    "braintree_sdk_data": base64EncodedBraintreeData,
            ] as [String : Any]
            
            if (paymentContextID != nil) {
                appSwitchParameters["resource_id"] = paymentContextID
            }
            
            var components = appSwitchBaseURLComponents()
            components?.percentEncodedQuery = BTURLUtils.queryString(with: appSwitchParameters)
            
            return components?.url
            
        } catch {
            return nil
        }
    }
    
    class func returnURL(scheme: String, result: String) -> URL? {
        var components = URLComponents.init(string: kXCallbackTemplate)
        components?.scheme = scheme
        components?.percentEncodedPath = "/vzero/auth/venmo/\(result)"
        return components?.url
    }
    
    class func appSwitchBaseURLComponents() -> URLComponents? {
        var components = URLComponents.init(string: kXCallbackTemplate)
        components?.scheme = kVenmoScheme
        components?.percentEncodedPath = "/vzero/auth";
        return components
    }
}
