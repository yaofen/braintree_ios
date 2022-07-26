#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

public class BTPayPalNativeCheckoutPatchRequest {
    public var patchRequest = PatchRequest()

    public init() {}

    public class BTShippingName {
        public var fullName: String?
        
        public init(fullName: String?) {
            self.fullName = fullName
        }

        public func createShippingName() -> PurchaseUnit.ShippingName {
            return PayPalCheckout.PurchaseUnit.ShippingName(fullName: fullName)
        }
    }

    public class BTOrderAddress {
        private let countryCode: String
        private let addressLine1: String?
        private let addressLine2: String?
        private let adminArea1: String?
        private let adminArea2: String?
        private let postalCode: String?

        public init(
            countryCode: String,
            addressLine1: String? = nil,
            addressLine2: String? = nil,
            adminArea1: String? = nil,
            adminArea2: String? = nil,
            postalCode: String? = nil
        ) {
            self.countryCode = countryCode
            self.addressLine1 = addressLine1
            self.addressLine2 = addressLine2
            self.adminArea1 = adminArea1
            self.adminArea2 = adminArea2
            self.postalCode = postalCode
        }

        public func createOrderAddress() -> OrderAddress {
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
            case pickuup
            case none
        }

        private let id: String
        private let label: String
        private let selected: Bool
        private let shippingType: ShippingType
        private let currencyCode: CurrencyCode
        private let value: String

        public init(
            id: String,
            label: String,
            selected: Bool,
            shippingType: ShippingType,
            currencyCode: CurrencyCode,
            value: String
        ) {
            self.id = id
            self.label = label
            self.selected = selected
            self.shippingType = shippingType
            self.currencyCode = currencyCode
            self.value = value
        }

        public func createShippingMethod() -> ShippingMethod {
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
