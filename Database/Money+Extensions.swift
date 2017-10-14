//
//  Money+Extensions.swift
//  Database
//
//  Created by Lobanov Dmitry on 26.09.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import CoreData

//MARK: Start
extension Money {
    class func resetStartCash(currency: Currencies, context: NSManagedObjectContext) -> Self {
        // create start cash
        let money = ldm_findFirstOrCreate(byAttribute: "currency", withValue: currency.rawValue, in: context)
        money.value = 100
        return money
    }
}

//MARK: Predicates
extension Money {
    class func currencyPredicate(currency: String) -> NSPredicate {
        let predicate = NSPredicate(format: "currency = %@", argumentArray: [currency])
        return predicate
    }
    class func currenciesPredicate(currencies: [String]) -> NSPredicate {
        let predicate = NSPredicate(format: "currency IN %@", argumentArray: [currencies])
        return predicate
    }
}
