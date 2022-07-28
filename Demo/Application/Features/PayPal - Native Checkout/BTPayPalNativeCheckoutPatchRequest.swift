#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

public class BTPayPalNativeCheckoutPatchRequest {
    public let patchRequest = PatchRequest()

    public init() {}

    public class BTShippingName {
        private var fullName: String? = nil
        
        public init() {}

        public func createShippingName(fullName: String?) -> PurchaseUnit.ShippingName {
            return PayPalCheckout.PurchaseUnit.ShippingName(fullName: fullName)
        }
    }

    public class BTOrderAddress {
        private let countryCode: String = ""
        private let addressLine1: String? = nil
        private let addressLine2: String? = nil
        private let adminArea1: String? = nil
        private let adminArea2: String? = nil
        private let postalCode: String? = nil

        public init() {}

        public func createOrderAddress(countryCode: String, addressLine1: String?, addressLine2: String?, adminArea1: String?, adminArea2: String?, postalCode: String?) -> OrderAddress {
            let address = PayPalCheckout.OrderAddress(
                countryCode: countryCode,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                adminArea1: adminArea1,
                adminArea2: adminArea2,
                postalCode: postalCode
            )

            return address
        }
    }
    
    public class BTShippingOptions {
        public enum ShippingType: Int {
            case shipping
            case pickup
            case none
        }

        private let id: String = ""
        private let label: String = ""
        private let selected: Bool = true
        private let shippingType: ShippingType = .shipping
        private let currencyCode: CurrencyCode = .usd
        private let value: String = ""

        public init() {}

        public func createShippingMethod(id: String, label: String, selected: Bool, shippingType: ShippingType, currencyCode: CurrencyCode, value: String) -> ShippingMethod {
            let shippingType = PayPalCheckout.ShippingType(rawValue: shippingType.rawValue)
            let shippingMethod = PayPalCheckout.ShippingMethod(
                id: id,
                label: label,
                selected: selected,
                type: shippingType ?? .none,
                amount: PayPalCheckout.UnitAmount(
                    currencyCode: currencyCode,
                    value: value
                )
            )
            return shippingMethod
        }
    }
}
