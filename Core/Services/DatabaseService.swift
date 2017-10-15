//
//  DatabaseService.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import DatabaseBeaver
import CoreData

class DatabaseService: BaseService {
    var baseCode: String {
        get {
            return DatabaseSettings.baseCode
        }
        set {
            DatabaseSettings.baseCode = newValue
        }
    }
    
    var container: DatabaseContainerProtocol?
    var accidentError: Error?
    var supplement: DatabaseSupplement?
    lazy var context: NSManagedObjectContext? = {
        return self.viewContext()
    }()
}

//MARK: Context and Stack.
extension DatabaseService {
    func checkStack() -> Bool {
        return container != nil && accidentError == nil && context != nil
    }
    func viewContext() -> NSManagedObjectContext? {
        return container?.viewContext()
    }
}

//MARK: DatabaseSupplement
extension DatabaseService {
    func fetchExchanges(delegate: NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController<Exchange>? {
        guard checkStack(), let context = context else {
            return nil
        }
        return supplement?.fetchExchanges(predicate: nil, delegate: delegate, context: context)
    }
    func fetchConversions(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<NSFetchRequestResult>? {
        guard checkStack(), let context = context else {
            return nil
        }
        return supplement?.fetchConversions(delegate: delegate, context: context)
    }
    
    func fetchQuotes(delegate: NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController<Quote>? {
        return self.fetchQuotes(predicate: nil, delegate: delegate)
    }
    
    func fetchQuotes(predicate: NSPredicate?, delegate: NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController<Quote>? {
        guard checkStack(), let context = context else {
            return nil
        }
        return supplement?.fetchQuotes(predicate: predicate, delegate: delegate, context: context)
    }
    
    func fetchMoney(delegate: NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController<Money>? {
        return self.fetchMoney(predicate: nil, delegate: delegate)
    }
    
    func fetchMoney(predicate: NSPredicate?, delegate: NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController<Money>? {
        guard checkStack(), let context = context else {
            return nil
        }
        return supplement?.fetchMoney(predicate: predicate, delegate: delegate, context: context)
    }
    
    func currencies() -> [String] {
        guard checkStack(), let context = context, let theSupplement = supplement else {
            return []
        }
        return theSupplement.currencies(context: context)
    }
    
    func save(block:@escaping ((NSManagedObjectContext?) -> Void), completion: ((Bool, Error?) -> Void)?) {
        guard checkStack() else {
            return
        }
        container?.save(block: block, completion: completion)
    }
}

//MARK: Conversion manipulation
extension DatabaseService {
    func delete(source: String, target: String, context:NSManagedObjectContext) throws {
        guard checkStack() else {
            return // throw error?
        }
        try Conversion.delete(source: source, target: target, context: context)
    }
    func insert(source: String, target: String, context: NSManagedObjectContext) throws {
        guard checkStack() else {
            return
        }
        try Conversion.insert(source: source, target: target, context: context)
    }
}

//MARK: Quote manipulation
extension DatabaseService {
    func upsert(source: String, target: String, quote: Double, timestamp: Double, context: NSManagedObjectContext) {
        guard checkStack() else {
            return
        }
        Quote.upsert(source: source, target: target, quote: quote, timestamp: timestamp, context: context)
    }
}

// MARK: ServicesInfoProtocol
extension DatabaseService {
    override var health: Bool {
        return !baseCode.isEmpty && checkStack()
    }
}

// MARK: ServicesSetupProtocol
extension DatabaseService {
    override func setup() {
        container = DatabaseContainer.container()
        container?.setupStack()
        supplement = DatabaseSupplement()
    }
    
    override func tearDown() {
        do {
            try container?.viewContext()?.save()
            container?.cleanupStack()
        }
        catch let error {
            LoggingService.logError("\(self) \(#function) error: \(error)")
        }
        //        MagicalRecord.cleanUp()
    }
}

// MARK: ServicesOnceProtocol
extension DatabaseService {
    override func runAtFirstTime() {
        self.resetCash()
    }
    func resetCash() {
        self.save(block: { context in
            if let theContext = context {
                self.supplement?.resetStartCash(context: theContext)
            }
        }, completion: nil)
    }
}
