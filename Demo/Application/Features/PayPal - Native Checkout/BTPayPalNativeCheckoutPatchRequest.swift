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

//    public class BTPurchaseUnit {
//        public init() {}
//
//        public func createNewTotal(currencyCode: String, orderAmount: String) -> PayPalCheckout.PurchaseUnit.Amount {
//            let newTotal = String(Double(orderAmount) ?? 0 + )
//
//        }
//    }

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
    
    public class BTShippingMethods {
        public let patchRequest = PatchRequest()

        public enum ShippingType: Int {
            case shipping
            case pickup
            case none
        }

        public init() {}
        public var shippingMethod = PayPalCheckout.ShippingMethod()

        public var testShippingMethod: [ShippingMethod] = []
        public func availableShippingMethod(
            id: String,
            label: String,
            selected: Bool,
            shippingType: ShippingType,
            currencyCode: CurrencyCode,
            value: String
        ) -> ShippingMethod {
            let shippingType = PayPalCheckout.ShippingType(rawValue: shippingType.rawValue)
            let shippingMethod = PayPalCheckout.ShippingMethod(
                id: id,
                label: label,
                selected: selected,
                type: shippingType ?? .none,
                amount: UnitAmount(currencyCode: currencyCode, value: value)
            )
            return shippingMethod
        }

        public func patchAmountAndShippingOptions(
            shippingMethods: [ShippingMethod],
            action: ShippingChangeAction,
            currencyCode: CurrencyCode,
            amountValue: String
        ) {
            let selectedMethod = shippingMethods.first { $0.selected }
            let selectedMethodPrice = Double(selectedMethod?.amount?.value ?? "0") ?? 0
            let newTotal = String(Double(amountValue) ?? 0 + selectedMethodPrice)

            patchRequest.replace(
                amount: PayPalCheckout.PurchaseUnit.Amount(
                    currencyCode: currencyCode, value: newTotal
                )
            )
            patchRequest.replace(shippingOptions: shippingMethods)

            action.patch(request: patchRequest) { _, _ in }
        }
    }
}
