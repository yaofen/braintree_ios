import Foundation
import AuthenticationServices

// TODO: move this to PaymentFlow
@objcMembers public class BTWebAuthenticationSession: NSObject {

    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        let authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: BTCoreConstants.callbackURLScheme,
            completionHandler: completion
        )

        authenticationSession.prefersEphemeralWebBrowserSession = true
        authenticationSession.presentationContextProvider = context

        authenticationSession.start()
    }
}

// TODO: move this to PaymentFlow
@objcMembers open class BTWebAuthenticationSessionClient: NSObject, ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 15, *) {
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = firstScene?.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        }
    }
}
