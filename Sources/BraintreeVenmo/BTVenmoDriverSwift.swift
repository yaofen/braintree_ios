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
        guard let venmoRequest = venmoRequest else {
            let error = 
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
}
