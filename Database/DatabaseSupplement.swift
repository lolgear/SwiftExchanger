//
//  DatabaseSupplement.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord
public class DatabaseSettings {
    private class DatabaseSettingsCompanion {
        static let storeName = "DatabaseSettings"
        static let attributeBaseCode = "baseCode"
    }
    
    public static var baseCode: String {
        get{
            let propertyName = DatabaseSettingsCompanion.attributeBaseCode
            return UserDefaults.standard.string(forKey: propertyName) ?? ""
        }
        set{
            let propertyName = DatabaseSettingsCompanion.attributeBaseCode
            UserDefaults.standard.set(newValue, forKey: propertyName)
        }
    }
}

public class DatabaseSupplement {
    public init() {}
}

//MARK: Fetch
extension DatabaseSupplement {
    public func fetchConversions(delegate: NSFetchedResultsControllerDelegate, context: NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult>? {
        return Conversion.ldm_fetchAllSorted(by: "addedAt", ascending: true, with: nil, groupBy: nil, delegate: delegate, context: context)
    }
    
    public func fetchQuotes(predicate: NSPredicate?, delegate: NSFetchedResultsControllerDelegate?, context: NSManagedObjectContext) -> NSFetchedResultsController<Quote>? {
        return Quote.ldm_fetchAllSorted(by: "targetCode", ascending: true, with: predicate, groupBy: nil, delegate: delegate, context: context) as? NSFetchedResultsController<Quote>
    }
    
    public func fetchMoney(predicate: NSPredicate?, delegate: NSFetchedResultsControllerDelegate?, context: NSManagedObjectContext) -> NSFetchedResultsController<Money>? {
        return Money.ldm_fetchAllSorted(by: "currency", ascending: true, with: predicate, groupBy: nil, delegate: delegate, context: context) as? NSFetchedResultsController<Money>
    }
    
    public func currencies(context: NSManagedObjectContext) -> [String] {
        return Quote.currencies(context: context).sorted()
    }
}

//MARK: Setup
extension DatabaseSupplement {
    public func resetStartCash(context: NSManagedObjectContext) {
        _ = Money.resetStartCash(currency: Currencies.EUR, context: context)
        _ = Money.resetStartCash(currency: Currencies.USD, context: context)
        _ = Money.resetStartCash(currency: Currencies.GBP, context: context)
    }
}
