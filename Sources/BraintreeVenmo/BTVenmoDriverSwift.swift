import Foundation
import UIKit
#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTVenmoDriverSwift: BTAppContextSwitcher {
    
    let BTVenmoDriverErrorDomain = "com.braintreepayments.BTVenmoDriverErrorDomain"
    let BTVenmoAppStoreUrl = "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428"
    
    /**
     Defaults to [UIApplication sharedApplication], but exposed for unit tests to inject test doubles
     to prevent calls to openURL. Its type is `id` and not `UIApplication` because trying to subclass
     UIApplication is not possible, since it enforces that only one instance can ever exist
    */
    private var application: Any

    /**
     Defaults to [NSBundle mainBundle], but exposed for unit tests to inject test doubles to stub values in infoDictionary
    */
    private var bundle: Bundle

    /**
     Defaults to [UIDevice currentDevice], but exposed for unit tests to inject different devices
     */
    private var device: UIDevice

    /**
     Exposed for testing to get the instance of BTAPIClient after it has been copied by `copyWithSource:integration:`
    */
    private var apiClient: BTAPIClient

    /**
     Stored property used to determine whether a venmo account nonce should be vaulted after an app switch return
     */
    private var shouldVault: Bool
    
    private var appSwitchCompletionBlock: (BTVenmoAccountNonce?, Error?)
    
    var appSwitchDriver: BTVenmoDriver
    
    func load () {
        if (self is BTAppContextSwitchDriver) {
            BTAppContextSwitcher.sharedInstance().register(BTVenmoDriverSwift.self as! BTAppContextSwitchDriver.Type)
            BTPaymentMethodNonceParser.shared().registerType("VenmoAccount") { venmoJSON in
                return BTVenmoAccountNonce.venmoAccount(with: venmoJSON)
            }
        }
    }
    
    /**
     Initialize a new Venmo driver instance.

     @param apiClient The API client
    */
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient.copy(with: .venmoApp, integration: apiClient.metadata.integration)
    }
    /**
     Initiates Venmo login via app switch, which returns a BTVenmoAccountNonce when successful.

     @param venmoRequest A Venmo request.
     @param completionBlock This completion will be invoked when app switch is complete or an error occurs.
        On success, you will receive an instance of `BTVenmoAccountNonce`; on failure, an error; on user
        cancellation, you will receive `nil` for both parameters.
    */
    public func tokenizeVenmoAccount(venmoRequest: BTVenmoRequest, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, configurationError in
            
            if let error = configurationError {
                completion(nil, error)
                return
            }
            
            if let configuration = configuration {
                if let error = self.verifyAppSwitch(configuration: configuration) {
                    completion(nil, error)
                    return
                }
                
                let merchantProfileID = venmoRequest.profileID != nil ? venmoRequest.profileID : configuration.venmoMerchantID
                
                let bundleDisplayName = self.bundle.object(forInfoDictionaryKey: "CFBundleDisplayName")
                
//                var metadata = self.apiClient.metadata.mutableCopy()
//                (metadata as Any).source = BTClientMetadataSourceType.venmoApp
                
                var inputParams = [
                    "paymentMethodUsage": venmoRequest.paymentMethodUsageAsString,
                    "merchantProfileId": merchantProfileID,
                    "customerClient": "MOBILE_APP",
                    "intent": "CONTINUE"
                ]
                
                if let displayName = venmoRequest.displayName {
                    inputParams["displayName"] = displayName
                }
                
                let params = [
                    "query": "mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }",
                    "variables": [
                        "input": inputParams
                    ] as [String : Any]
                ] as [String : Any]
                
                self.apiClient.post("", parameters: params, httpType: .graphQLAPI) { body, response, error in
                    if error != nil {
                        completion(nil, BTVenmoError.invalidRequestURL)
                        return
                    }
                    
                    if let body = body {
                        let paymentContextID = body["data"]["createVenmoPaymentContext"]["venmoPaymentContext"]["id"]
                        
//                        if paymentContextID == nil {
//                            completion(nil, BTVenmoError.invalidRequestURL)
//                            return
//                        }
                        
                        let appSwitchURL = BTVenmoAppSwitchRequestURL.appSwitch(forMerchantID: <#T##String#>, accessToken: <#T##String#>, returnURLScheme: <#T##String#>, bundleDisplayName: <#T##String#>, environment: <#T##String#>, paymentContextID: <#T##String?#>, metadata: <#T##BTClientMetadata#>)
                        
                    }
                }
            }
            
        }
    }
    
    /**
     Returns true if the proper Venmo app is installed and configured correctly, returns false otherwise.
    */
    public func isiOSAppAvailableForAppSwitch() -> Bool {}

    /**
     Switches to the iTunes App Store to download the Venmo app.
     */
    public func openVenmoAppPageInAppStore() {}
    
    func verifyAppSwitch(configuration: BTConfiguration) -> Error? {
        var error: Error?
        if !configuration.isVenmoEnabled {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.initiate.error.disabled")
            if error != nil {
                error = BTVenmoError.disabled
            }
        }
        
        if !isiOSAppAvailableForAppSwitch() {
            apiClient.sendAnalyticsEvent("ios.pay-with-venmo.appswitch.initiate.error.unavailable")
            error = BTVenmoError.disabled
        }
        
        guard bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") != nil else {
            error = BTVenmoError.bundleDisplayNameMissing
        }
        return error
    }
}
