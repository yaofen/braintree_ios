import BraintreeCore

extension BTJSON {

    func asCreditFinancingAmount() -> BTPayPalCreditFinancingAmount? {
        guard self.isObject,
              let currency = self["currency"].asString(),
              let value = self["value"].asString() else {
                  return nil
              }
        
        return BTPayPalCreditFinancingAmount(currency: currency, value: value)
    }
    
    func asCreditFinancing() -> BTPayPalCreditFinancing? {
        guard self.isObject else { return nil }
        
        let isCardAmountImmutable = self["cardAmountImmutable"].isTrue
        let monthlyPayment = self["monthlyPayment"].asCreditFinancingAmount()
        let payerAcceptance = self["payerAcceptance"].isTrue
        let term = self["term"].asIntegerOrZero()
        let totalCost = self["totalCost"].asCreditFinancingAmount()
        let totalInterest = self["totalInterest"].asCreditFinancingAmount()
        
        return BTPayPalCreditFinancing(
            cardAmountImmutable: isCardAmountImmutable,
            monthlyPayment: monthlyPayment,
            payerAcceptance: payerAcceptance,
            term: term,
            totalCost: totalCost,
            totalInterest: totalInterest
        )
    }
}
