//
//  MoneyFormatter.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
class MoneyFormatter {
    class func moneyFromDouble(value: Double, currency: String?) -> String? {
        let decimalNumber = NSDecimalNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        if let theCurrency = currency {
            formatter.numberStyle = .currency
            formatter.currencyCode = theCurrency
        }
        return formatter.string(from: decimalNumber)
    }
    class func numberWithFractionFromDouble(value: Double) -> String? {
        return self.moneyFromDouble(value: value, currency: nil)
    }
}
