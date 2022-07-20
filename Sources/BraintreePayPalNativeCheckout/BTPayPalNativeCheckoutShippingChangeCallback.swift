#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

/// For merchants to make shipping changes
public class BTPayPalNativeCheckoutShippingChangeCallback {

    // MARK: - Public
    
    public enum ShippingChangeType: Int {
        case shippingAddress
        case shippingMethod
    }

    /// The method in which payer wants to get their items
    public enum ShippingType: Int {
        case none
        case shipping
        case pickup
    }

    // ShippingChange
    /// Type of shipping change
    public var shippingChangeType: ShippingChangeType = .shippingMethod
    /// Current selected shipping address
    public var selectedShippingAddress: ShippingChangeAddress
    /// List of available shipping methods
    public var shippingMethods: [ShippingMethod]
    /// Currently selected shipping method
    public var selectedShippingMethod: ShippingMethod? { shippingMethods.first { $0.selected } }
    public let payToken: String = ""
    public let paymentID: String? = ""
    public let billingToken: String? = ""

    // Shipping Change Address
    public var addressID: String? = ""
    public var fullName: String? = ""
    public var city: String? = ""
    public var state: String? = ""
    public var postalCode: String? = ""
    public var country: String? = ""
    
    // Shipping Method
    /// Unique ID that identifies a payer-selected shipping option.
    public var id: String = ""
    /// Description that payer seems, which helps them choose an appropriate
    /// shipping option
    public var label: String = ""
    /// If set to true, merchant expects the shipping option to be selected for the
    /// buyer when they view the shipping options with;in the PayPal Checkout experience
    public var selected: Bool = true
    /// The method in which payer wants to get their items
    public var shippingType: ShippingType = .none
    /// Merchant currency
    public var currencyCode: CurrencyCode = .usd
    /// Shippng cost for selected option
    public var amountValue: String = ""
    /// The API caller-provided external ID for the purchase unit if more than
    /// one purchase unit was provided.
    public var referenceID: String? = nil

    public let patchRequest = PatchRequest()

    /// Replaces shipping options of the order request
    public func replaceShippingOptions() {
        patchRequest.replace(
            shippingOptions: [getShippingMethod()],
            referenceId: referenceID
        )
    }

    /// Adds shipping options of the order request
    public func addShippingOptions() {
        patchRequest.add(
            shippingOptions: [getShippingMethod()],
            referenceId: referenceID
        )
    }

    public init() {
        selectedShippingAddress = ShippingChangeAddress.init(
            addressID: addressID,
            fullName: fullName,
            city: city,
            state: state,
            postalCode: postalCode,
            country: country
        )
        
    }

    // MARK: - Internal

    internal func getShippingMethod() -> ShippingMethod {
        let shippingType = PayPalCheckout.ShippingType.init(rawValue: shippingType.rawValue)

        return ShippingMethod.init(
            id: id,
            label: label,
            selected: selected,
            type: shippingType ?? .none,
            amount: .init(currencyCode: currencyCode, value: amountValue)
        )
    }
}
