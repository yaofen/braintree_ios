import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePaymentFlow)
import BraintreePaymentFlow
#endif

/// Extension on BTPaymentFlowClient for 3D Secure
extension BTPaymentFlowClient {

    // MARK: - Internal Methods

//    func performThreeDSecureLookup(
//        _ request: BTThreeDSecureRequest,
//        completion: @escaping (BTThreeDSecureResult?, Error?) -> Void
//    ) {
//        apiClient().fetchOrReturnRemoteConfiguration { _, error in
//            if let error {
//                completion(nil, error)
//                return
//            }
//
//            let customer: [String: String] = [:]
//
//            var requestParameters: [String: Any] = [
//                "amount": request.amount ?? 0,
//                "customer": customer,
//                "requestedThreeDSecureVersion": "2",
//                "dfReferenceId": request.dfReferenceID ?? "",
//                "accountType": request.accountType.stringValue ?? "",
//                "challengeRequested": request.challengeRequested,
//                "exemptionRequested": request.exemptionRequested,
//                "requestedExemptionType": request.requestedExemptionType.stringValue ?? "",
//                "dataOnlyRequested": request.dataOnlyRequested
//            ]
//
//            if request.cardAddChallenge == .requested {
//                requestParameters["cardAdd"] = true
//            } else if request.cardAddChallenge == .notRequested {
//                requestParameters["cardAdd"] = false
//            }
//
//            var additionalInformation: [String: String?] = [
//                "mobilePhoneNumber": request.mobilePhoneNumber,
//                "email": request.email,
//                "shippingMethod": request.shippingMethod.stringValue
//            ]
//
//            additionalInformation = additionalInformation.merging(request.billingAddress?.asParameters(withPrefix: "billing") ?? [:]) { $1 }
//            additionalInformation = additionalInformation.merging(request.additionalInformation?.asParameters() ?? [:]) { $1 }
//
//            requestParameters["additionalInfo"] = additionalInformation
//            requestParameters = requestParameters.compactMapValues { $0 }
//
//            guard let urlSafeNonce = request.nonce?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//                completion(nil, BTThreeDSecureError.failedAuthentication("Tokenized card nonce is required."))
//                return
//            }
//
//            self.apiClient().post(
//                "v1/payment_methods/\(urlSafeNonce)/three_d_secure/lookup",
//                parameters: requestParameters
//            ) { body, _, error in
//                if let error = error as NSError? {
//                    if error.code == BTCoreConstants.networkConnectionLostCode {
//                        self.apiClient().sendAnalyticsEvent("ios.three-d-secure.lookup.network-connection.failure")
//                    }
//
//                    // Provide more context for card validation error when status code 422
//                    if error.domain == BTCoreConstants.httpErrorDomain,
//                        error.code == 2, // BTHTTPError.errorCode.clientError
//                       let urlResponseError = error.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse,
//                       urlResponseError.statusCode == 422 {
//                        var userInfo: [String: Any] = error.userInfo
//                        let errorBody = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
//
//                        if let message = errorBody?["error"]["message"], message.isString {
//                            userInfo[NSLocalizedDescriptionKey] = message.asString()
//                        }
//
//                        if let threeDSecureInfo = errorBody?["threeDSecureInfo"], threeDSecureInfo.isObject {
//                            let infoKey = "com.braintreepayments.BTThreeDSecureFlowInfoKey"
//                            userInfo[infoKey] = threeDSecureInfo.asDictionary()
//                        }
//
//                        if let error = errorBody?["error"], error.isObject {
//                            let validationErrorsKey = "com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey"
//                            userInfo[validationErrorsKey] = error.asDictionary()
//                        }
//
//                        completion(nil, BTThreeDSecureError.failedLookup(userInfo))
//                        return
//                    }
//
//                    completion(nil, error)
//                    return
//                }
//
//                guard let body else {
//                    completion(nil, BTThreeDSecureError.noBodyReturned)
//                    return
//                }
//
//                completion(BTThreeDSecureResult(json: body), nil)
//                return
//            }
//        }
//    }
}
