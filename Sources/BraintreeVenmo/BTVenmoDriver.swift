import Foundation
import UIKit
#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTVenmoDriver: BTAppContextSwitcher {
    
    public let BTVenmoDriverErrorDomain = "com.braintreepayments.BTVenmoDriverErrorDomain"
    let BTVenmoAppStoreUrl = "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428"
    
    /**
     Defaults to [UIApplication sharedApplication], but exposed for unit tests to inject test doubles
     to prevent calls to openURL. Its type is `id` and not `UIApplication` because trying to subclass
     UIApplication is not possible, since it enforces that only one instance can ever exist
    */
    var application: Any = UIApplication.shared

    /**
     Defaults to [NSBundle mainBundle], but exposed for unit tests to inject test doubles to stub values in infoDictionary
    */
    var bundle: Bundle = Bundle.main

    /**
     Defaults to [UIDevice currentDevice], but exposed for unit tests to inject different devices
     */
    var device: UIDevice = UIDevice.current

    /**
     Exposed for testing to get the instance of BTAPIClient after it has been copied by `copyWithSource:integration:`
    */
    var apiClient: BTAPIClient

    /**
     Stored property used to determine whether a venmo account nonce should be vaulted after an app switch return
     */
    var shouldVault: Bool = false
    
    var appSwitchCompletionBlock: (BTVenmoAccountNonce?, Error?)
    
//    var appSwitchDriver: BTVenmoDriver
    
    func load () {
        if (self is BTAppContextSwitchDriver) {
            BTAppContextSwitcher.sharedInstance().register(BTVenmoDriver.self as! BTAppContextSwitchDriver.Type)
            BTPaymentMethodNonceParser.shared().registerType("VenmoAccount") { venmoJSON in
                return BTVenmoAccountNonce(venmoAccountJSON: venmoJSON)
            }
        }
    }
    
    /**
     Initialize a new Venmo driver instance.

     @param apiClient The API client
    */
    @objc(initWithAPIClient:)
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
    public func tokenizeVenmoAccount(with venmoRequest: BTVenmoRequest, completion: @escaping (BTVenmoAccountNonce?, Error?) -> Void) {
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
                        
//                        let appSwitchURL = BTVenmoAppSwitchRequestURL.appSwitch(forMerchantID: <#T##String#>, accessToken: <#T##String#>, returnURLScheme: <#T##String#>, bundleDisplayName: <#T##String#>, environment: <#T##String#>, paymentContextID: <#T##String?#>, metadata: <#T##BTClientMetadata#>)
                        
                    }
                }
            }
            
        }
    }
    
    /**
     Returns true if the proper Venmo app is installed and configured correctly, returns false otherwise.
    */
    public func isiOSAppAvailableForAppSwitch() -> Bool {
        return true
    }

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
        
        if bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") != nil {
            error = BTVenmoError.bundleDisplayNameMissing
        }
        return error
    }
}

//@interface BTVenmoDriver ()
//
//@property (nonatomic, copy) void (^appSwitchCompletionBlock)(BTVenmoAccountNonce *, NSError *);
//
//@end
//
//NSString * const BTVenmoDriverErrorDomain = @"com.braintreepayments.BTVenmoDriverErrorDomain";
//NSString * const BTVenmoAppStoreUrl = @"https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428";
//
//@implementation BTVenmoDriver
//
//static BTVenmoDriver *appSwitchedDriver;
//
//+ (void)load {
//    if (self == [BTVenmoDriver class]) {
//        [[BTAppContextSwitcher sharedInstance] registerAppContextSwitchDriver:self];
//        [[BTPaymentMethodNonceParser sharedParser] registerType:@"VenmoAccount" withParsingBlock:^BTPaymentMethodNonce * _Nullable(BTJSON * _Nonnull venmoJSON) {
//            return [BTVenmoAccountNonce venmoAccountWithJSON:venmoJSON];
//        }];
//    }
//}
//
//- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
//    if (self = [super init]) {
//        _apiClient = [apiClient copyWithSource:BTClientMetadataSourceVenmoApp integration:apiClient.metadata.integration];
//    }
//    return self;
//}
//
//- (instancetype)init {
//    return nil;
//}
//
//#pragma mark - Accessors
//
//- (id)application NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.") {
//    if (!_application) {
//        _application = [UIApplication sharedApplication];
//    }
//    return _application;
//}
//
//- (NSBundle *)bundle {
//    if (!_bundle) {
//        _bundle = [NSBundle mainBundle];
//    }
//    return _bundle;
//}
//
//- (UIDevice *)device {
//    if (!_device) {
//        _device = [UIDevice currentDevice];
//    }
//    return _device;
//}
//
//- (NSString *)returnURLScheme {
//    if (!_returnURLScheme) {
//        _returnURLScheme = [BTAppContextSwitcher sharedInstance].returnURLScheme;
//    }
//    return _returnURLScheme;
//}
//
//#pragma mark - Tokenization
//
//- (void)tokenizeVenmoAccountWithVenmoRequest:(BTVenmoRequest *)venmoRequest completion:(void (^)(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error))completionBlock {
//    if (!venmoRequest) {
//        NSError *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                             code:BTVenmoDriverErrorTypeIntegration
//                                         userInfo:@{NSLocalizedDescriptionKey: @"BTVenmoDriver failed because BTVenmoRequest is nil."}];
//        completionBlock(nil, error);
//        return;
//    }
//
//    if (!self.apiClient) {
//        NSError *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                             code:BTVenmoDriverErrorTypeIntegration
//                                         userInfo:@{NSLocalizedDescriptionKey: @"BTVenmoDriver failed because BTAPIClient is nil."}];
//        completionBlock(nil, error);
//        return;
//    }
//
//    if (self.returnURLScheme == nil || [self.returnURLScheme isEqualToString:@""]) {
//        [[BTLogger sharedLogger] critical:@"Venmo requires a return URL scheme to be configured via [BTAppContextSwitcher setReturnURLScheme:]"];
//        NSError *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                             code:BTVenmoDriverErrorTypeAppNotAvailable
//                                         userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app switch to Venmo."}];
//        completionBlock(nil, error);
//        return;
//    } else if (!self.bundle.bundleIdentifier || ![self.returnURLScheme hasPrefix:self.bundle.bundleIdentifier]) {
//        [[BTLogger sharedLogger] critical:@"Venmo requires [BTAppContextSwitcher setReturnURLScheme:] to be configured to begin with your app's bundle ID (%@). Currently, it is set to (%@) ", [NSBundle mainBundle].bundleIdentifier, self.returnURLScheme];
//    }
//
//    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *configurationError) {
//        if (configurationError) {
//            completionBlock(nil, configurationError);
//            return;
//        }
//
//        NSError *error;
//        if (![self verifyAppSwitchWithConfiguration:configuration error:&error]) {
//            completionBlock(nil, error);
//            return;
//        }
//
//        NSString *merchantProfileID = venmoRequest.profileID ?: configuration.venmoMerchantID;
//        NSString *bundleDisplayName = [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//
//        BTMutableClientMetadata *metadata = [self.apiClient.metadata mutableCopy];
//        metadata.source = BTClientMetadataSourceVenmoApp;
//
//        NSMutableDictionary *inputParams = [@{
//            @"paymentMethodUsage": venmoRequest.paymentMethodUsageAsString,
//            @"merchantProfileId": merchantProfileID,
//            @"customerClient": @"MOBILE_APP",
//            @"intent": @"CONTINUE"
//        } mutableCopy];
//
//        if (venmoRequest.displayName) {
//            inputParams[@"displayName"] = venmoRequest.displayName;
//        }
//
//        NSDictionary *params = @{
//            @"query": @"mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }",
//            @"variables": @{
//                @"input": inputParams
//            }
//        };
//
//        [self.apiClient POST:@"" parameters:params httpType:BTAPIClientHTTPTypeGraphQLAPI completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *err) {
//            if (err) {
//                NSError *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                                     code:BTVenmoDriverErrorTypeInvalidRequestURL
//                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to fetch a Venmo paymentContextID while constructing the requestURL."}];
//                completionBlock(nil, error);
//                return;
//            }
//
//            NSString *paymentContextID = [body[@"data"][@"createVenmoPaymentContext"][@"venmoPaymentContext"][@"id"] asString];
//            if (paymentContextID == nil) {
//                NSError *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                                     code:BTVenmoDriverErrorTypeInvalidRequestURL
//                                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support."}];
//                completionBlock(nil, error);
//                return;
//            }
//
//            NSURL *appSwitchURL = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:merchantProfileID
//                                                                            accessToken:configuration.venmoAccessToken
//                                                                        returnURLScheme:self.returnURLScheme
//                                                                      bundleDisplayName:bundleDisplayName
//                                                                            environment:configuration.venmoEnvironment
//                                                                       paymentContextID:paymentContextID
//                                                                               metadata:self.apiClient.metadata];
//            [self performAppSwitch:appSwitchURL shouldVault:venmoRequest.vault completion:completionBlock];
//        }];
//    }];
//}
//
//#pragma mark - Vaulting
//
//- (void)vaultVenmoAccountNonce:(NSString *)nonce {
//    NSMutableDictionary *params = [NSMutableDictionary new];
//    params[@"venmoAccount"] = @{
//                                @"nonce": nonce
//                                };
//
//    [self.apiClient POST:@"v1/payment_methods/venmo_accounts"
//              parameters:params
//              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
//                  if (error) {
//                      [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.vault.failure"];
//                      self.appSwitchCompletionBlock(nil, error);
//                  } else {
//                      [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.vault.success"];
//                      BTJSON *venmoAccountJson = body[@"venmoAccounts"][0];
//                      self.appSwitchCompletionBlock([BTVenmoAccountNonce venmoAccountWithJSON:venmoAccountJson], venmoAccountJson.asError);
//                  }
//                  self.appSwitchCompletionBlock = nil;
//    }];
//}
//
//#pragma mark - App switch
//
//- (void)performAppSwitch:(NSURL *)appSwitchURL shouldVault:(BOOL)vault completion:(void (^)(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error))completionBlock {
//    if (!appSwitchURL) {
//        NSError *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                             code:BTVenmoDriverErrorTypeInvalidRequestURL
//                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to create Venmo app switch request URL."}];
//        completionBlock(nil, error);
//        return;
//    }
//
//    [self.application openURL:appSwitchURL options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
//        [self invokedOpenURLSuccessfully:success shouldVault:vault completion:completionBlock];
//    }];
//}
//
//- (void)invokedOpenURLSuccessfully:(BOOL)success shouldVault:(BOOL)vault completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *configurationError))completionBlock {
//    self.shouldVault = success && vault;
//
//    if (success) {
//        self.appSwitchCompletionBlock = completionBlock;
//        appSwitchedDriver = self;
//        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.initiate.success"];
//    } else {
//        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.initiate.error.failure"];
//        NSError *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                    code:BTVenmoDriverErrorTypeAppSwitchFailed
//                                userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app switch to Venmo."}];
//        completionBlock(nil, error);
//    }
//}
//
//- (BOOL)isiOSAppAvailableForAppSwitch {
//    return [self.application canOpenURL:[BTVenmoAppSwitchRequestURL baseAppSwitchURL]];
//}
//
//#pragma mark - App switch return
//
//+ (void)handleReturnURL:(NSURL *)url {
//    [appSwitchedDriver handleOpenURL:url];
//    appSwitchedDriver = nil;
//}
//
//+ (BOOL)canHandleReturnURL:(NSURL *)url {
//    return [BTVenmoAppSwitchReturnURL isValidURL:url];
//}
//
//- (void)handleOpenURL:(NSURL *)url {
//    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];
//
//    switch (returnURL.state) {
//        case BTVenmoAppSwitchReturnURLStateSucceededWithPaymentContext: {
//            NSDictionary *params = @{
//                @"query": @"query PaymentContext($id: ID!) { node(id: $id) { ... on VenmoPaymentContext { paymentMethodId userName payerInfo { firstName lastName phoneNumber email externalId userName } } } }",
//                @"variables": @{ @"id": returnURL.paymentContextID }
//            };
//
//            [self.apiClient POST:@"" parameters:params httpType:BTAPIClientHTTPTypeGraphQLAPI completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {
//                if (error) {
//                    [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.client-failure"];
//                    self.appSwitchCompletionBlock(nil, error);
//                    self.appSwitchCompletionBlock = nil;
//                    return;
//                }
//
//                BTVenmoAccountNonce *venmoAccountNonce = [[BTVenmoAccountNonce alloc] initWithPaymentContextJSON:body];
//                [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.success"];
//
//                if (self.shouldVault && self.apiClient.clientToken != nil) {
//                    [self vaultVenmoAccountNonce:venmoAccountNonce.nonce];
//                } else {
//                    self.appSwitchCompletionBlock(venmoAccountNonce, nil);
//                    self.appSwitchCompletionBlock = nil;
//                }
//            }];
//            break;
//        }
//        case BTVenmoAppSwitchReturnURLStateSucceeded: {
//
//            NSError *error = nil;
//            if (!returnURL.nonce) {
//                error = [NSError errorWithDomain:BTVenmoDriverErrorDomain code:BTVenmoDriverErrorTypeInvalidReturnURL userInfo:@{NSLocalizedDescriptionKey: @"Return URL is missing nonce"}];
//            } else if (!returnURL.username) {
//                error = [NSError errorWithDomain:BTVenmoDriverErrorDomain code:BTVenmoDriverErrorTypeInvalidReturnURL userInfo:@{NSLocalizedDescriptionKey: @"Return URL is missing username"}];
//            }
//
//            if (error) {
//                [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.client-failure"];
//                self.appSwitchCompletionBlock(nil, error);
//                self.appSwitchCompletionBlock = nil;
//                return;
//            }
//
//            [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.success"];
//
//            if (self.shouldVault && self.apiClient.clientToken != nil) {
//                [self vaultVenmoAccountNonce:returnURL.nonce];
//            } else {
//                BTJSON *json = [[BTJSON alloc] initWithValue:@{
//                    @"nonce": returnURL.nonce,
//                    @"details": @{@"username": returnURL.username},
//                    @"description": returnURL.username
//                }];
//                BTVenmoAccountNonce *card = [BTVenmoAccountNonce venmoAccountWithJSON:json];
//                self.appSwitchCompletionBlock(card, nil);
//                self.appSwitchCompletionBlock = nil;
//            }
//            break;
//        }
//        case BTVenmoAppSwitchReturnURLStateFailed: {
//            [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.failed"];
//            self.appSwitchCompletionBlock(nil, returnURL.error);
//            self.appSwitchCompletionBlock = nil;
//            break;
//        }
//        case BTVenmoAppSwitchReturnURLStateCanceled: {
//            [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.handle.cancel"];
//            self.appSwitchCompletionBlock(nil, nil);
//            self.appSwitchCompletionBlock = nil;
//            break;
//        }
//        default:
//            // should not happen
//            break;
//    }
//}
//
//#pragma mark - App Store switch
//
//- (void)openVenmoAppPageInAppStore {
//    NSURL *venmoAppStoreUrl = [NSURL URLWithString:BTVenmoAppStoreUrl];
//    [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.app-store.invoked"];
//    [self.application openURL:venmoAppStoreUrl
//                      options:[NSDictionary dictionary]
//            completionHandler:nil];
//}
//
//#pragma mark - Helpers
//
//- (BOOL)verifyAppSwitchWithConfiguration:(BTConfiguration *)configuration error:(NSError * __autoreleasing *)error {
//
//    if (!configuration.isVenmoEnabled) {
//        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.initiate.error.disabled"];
//        if (error) {
//            *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                         code:BTVenmoDriverErrorTypeDisabled
//                                     userInfo:@{ NSLocalizedDescriptionKey:@"Venmo is not enabled for this merchant account." }];
//        }
//        return NO;
//    }
//
//    if (![self isiOSAppAvailableForAppSwitch]) {
//        [self.apiClient sendAnalyticsEvent:@"ios.pay-with-venmo.appswitch.initiate.error.unavailable"];
//        if (error) {
//            *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                         code:BTVenmoDriverErrorTypeAppNotAvailable
//                                     userInfo:@{ NSLocalizedDescriptionKey:@"The Venmo app is not installed on this device, or it is not configured or available for app switch." }];
//        }
//        return NO;
//    }
//
//    NSString *bundleDisplayName = [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//    if (!bundleDisplayName) {
//        if (error) {
//            *error = [NSError errorWithDomain:BTVenmoDriverErrorDomain
//                                         code:BTVenmoDriverErrorTypeBundleDisplayNameMissing
//                                     userInfo:@{NSLocalizedDescriptionKey: @"CFBundleDisplayName must be non-nil. Please set 'Bundle display name' in your Info.plist."}];
//        }
//        return NO;
//    }
//
//    return YES;
//}
//
//@end
