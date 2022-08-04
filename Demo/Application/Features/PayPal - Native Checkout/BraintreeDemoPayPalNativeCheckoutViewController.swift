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

    func shippingMethods(for city: String?) -> [ShippingMethod] {
        let btShippingMethods = BTPayPalNativeCheckoutPatchRequest.BTShippingMethods()
        switch city {
            // Cities manually added by merchant
        case "San Fransisco":
            [btShippingMethods.availableShippingMethod(
                    id: "Pickup",
                    label: "Pickup in store",
                    selected: false,
                    shippingType: .pickup,
                    currencyCode: .usd,
                    value: "1.23"
                ),
                btShippingMethods.availableShippingMethod(
                    id: "Shipping",
                    label: "Free shipping",
                    selected: true,
                    shippingType: .shipping,
                    currencyCode: .usd,
                    value: "1.23"
                ),
            ]
        default:
            // Defaults to 1 pickup and 1 shipping. Shipping selected.
            [btShippingMethods.availableShippingMethod(
                    id: "Pickup1",
                    label: "Pickup in store",
                    selected: false,
                    shippingType: .pickup,
                    currencyCode: .usd,
                    value: "1.23"
                ),
                btShippingMethods.availableShippingMethod(
                    id: "Shipping2",
                    label: "Free shipping",
                    selected: false,
                    shippingType: .shipping,
                    currencyCode: .usd,
                    value: "0.00"
                ),
            ]
        }
    }

    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Native Checkout using BTPayPalNativeCheckout")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalNativeCheckoutRequest(amount: "4.30")
        let btPatchRequest = BTPayPalNativeCheckoutPatchRequest().patchRequest
        let btShippingMethods = BTPayPalNativeCheckoutPatchRequest.BTShippingMethods()
        let sampleShippingMethods = [
            btShippingMethods.availableShippingMethod(
                id: "Pickup1",
                label: "Pickup in store",
                selected: false,
                shippingType: .pickup,
                currencyCode: .usd,
                value: "1.23"
            ),
            btShippingMethods.availableShippingMethod(
                id: "Shipping2",
                label: "Free shipping",
                selected: false,
                shippingType: .shipping,
                currencyCode: .usd,
                value: "0.00"
            ),
        ]

        request.isShippingAddressEditable = true
        request.isShippingAddressRequired = true

        request.onShippingChange = { change, action in
            switch change.type {
            case .shippingAddress:
                // If user selected new address, fetch available shipping methods for the address
                let availableShippingMethods = self.shippingMethods(for: change.selectedShippingAddress.city)

                if !availableShippingMethods.isEmpty {
                    // The order's new total will be the order amount value `amountValue` + default shipping option price
                    // The default shipping option is the option where `selected == true`
                    btShippingMethods.patchAmountAndShippingOptions(shippingMethods: availableShippingMethods, action: action, currencyCode: .usd, amountValue: request.amount)
                }
                else {
                    // Don't support this address if no shipping methods available
                    action.reject()
                }

            case .shippingMethod:
                // The order's new total will be the order amount value `amountValue` + the selected shipping option's price
                btShippingMethods.patchAmountAndShippingOptions(shippingMethods: sampleShippingMethods, action: action, currencyCode: .usd, amountValue: request.amount)
            }
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
