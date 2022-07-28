import Foundation
import UIKit
import BraintreePayPalNativeCheckout

class BraintreeDemoPayPalNativeCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {
    lazy var payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

    override func createPaymentButton() -> UIView! {
        let payPalCheckoutButton = UIButton(type: .system)
        payPalCheckoutButton.setTitle("One Time Checkout", for: .normal)
        payPalCheckoutButton.setTitleColor(.blue, for: .normal)
        payPalCheckoutButton.setTitleColor(.lightGray, for: .highlighted)
        payPalCheckoutButton.setTitleColor(.lightGray, for: .disabled)
        payPalCheckoutButton.addTarget(self, action: #selector(tappedPayPalCheckout), for: .touchUpInside)
        payPalCheckoutButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let payPalVaultButton = UIButton(type: .system)
        payPalVaultButton.setTitle("Vault Checkout", for: .normal)
        payPalVaultButton.setTitleColor(.blue, for: .normal)
        payPalVaultButton.setTitleColor(.lightGray, for: .highlighted)
        payPalVaultButton.setTitleColor(.lightGray, for: .disabled)
        payPalVaultButton.addTarget(self, action: #selector(tappedPayPalVault), for: .touchUpInside)
        payPalVaultButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stackView = UIStackView(arrangedSubviews: [payPalCheckoutButton, payPalVaultButton])
        stackView.axis = .vertical
        stackView.spacing = 5

        return stackView
    }
    
    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Native Checkout using BTPayPalNativeCheckout")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalNativeCheckoutRequest(amount: "4.30")
        let btPatchRequest = BTPayPalNativeCheckoutPatchRequest().patchRequest
        let btShippingName = BTPayPalNativeCheckoutPatchRequest.BTShippingName()
        let btOrderAddress = BTPayPalNativeCheckoutPatchRequest.BTOrderAddress()
        let btShippingOptions = BTPayPalNativeCheckoutPatchRequest.BTShippingOptions()

        request.isShippingAddressEditable = true
        request.isShippingAddressRequired = true
        
        request.onShippingChange = { change, action in
            action.patch(request: btPatchRequest) { _, _ in }
            btPatchRequest.add(
                shippingAddress: btOrderAddress.createOrderAddress(
                    countryCode: "US",
                    addressLine1: nil,
                    addressLine2: nil,
                    adminArea1: nil,
                    adminArea2: nil,
                    postalCode: nil
                )
            )
            btPatchRequest.replace(
                shippingOptions: [
                    btShippingOptions.createShippingMethod(
                        id: "123",
                        label: "test",
                        selected: true,
                        shippingType: .shipping,
                        currencyCode: .aud,
                        value: "1.23")
                ]
            )
            btPatchRequest.add(shippingName: btShippingName.createShippingName(fullName: "test"))
        }

        payPalNativeCheckoutClient.tokenizePayPalAccount(with: request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.nonceStringCompletionBlock(nonce.nonce)
        }
    }

    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalNativeCheckout")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalNativeVaultRequest()
        request.activeWindow = self.view.window

        payPalNativeCheckoutClient.tokenizePayPalAccount(with: request) { nonce, error in
            sender.isEnabled = true

            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.nonceStringCompletionBlock(nonce.nonce)
        }
    }
}
