//
//  Exchange+Extensions.swift
//  Database
//
//  Created by Lobanov Dmitry on 26.09.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import CoreData

// MARK: Sources and Targets Protocol
extension Exchange: SourcesAndTargetsProtocol {
    static func find(source: String, target: String, context: NSManagedObjectContext) -> NSManagedObject? {
        return ldm_findFirst(with: sourceAndTargetPredicate(source: source, target: target), in: context)
    }
}

// MARK: Predicates.
extension Exchange {
    class func exactPredicate(sourceCode: String, targetCode: String, at timestamp: Double) -> NSPredicate {
        let predicate = NSPredicate(format: "timestamp = %@", argumentArray: [timestamp])
        let result = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, self.sourceAndTargetPredicate(source: sourceCode, target: targetCode)])
        return result
    }
}

// MARK: Errors
extension Exchange {
    enum Errors: DatabaseErrors {
        static let domain = "org.opensource.swift_exchanger.database.exchanges_model"
        case transactionsError(String, String, Double, Double)
        case collisionError(String, String, Double)
        case insufficientBalance(String, String)
        case entryDoesNotExist(String)
        var code : Int {
            switch self {
            case .transactionsError(_, _, _, _): return -401
            case .collisionError(_, _, _): return -402
            case .insufficientBalance(_, _): return -302
            case .entryDoesNotExist(_): return -303
            }
        }
        var message : String {
            switch self {
            case let .transactionsError(from, to, timestamp, updated):
                return "Transaction \(from) -> \(to) can't be performed because \(timestamp) < \(updated)"
            case let .collisionError(from, to, timestamp):
                return "Internal conflict between transactions occured. Transaction exists. \(from) -> \(to) at \(timestamp)"
            case let .insufficientBalance(lhs, rhs): return "Insufficient balance! from \(lhs) to \(rhs)"
            case let .entryDoesNotExist(entry): return "Entry \(entry) does not exist"
            }
        }
    }
}

//MARK: Validation.
extension Exchange {
    class func checkTimestamps(created: Double, modified: Double) -> Bool {
        // created date should be greater than zero as modified date.
        let result = (created > 0) && (modified > 0)
        return result
    }
    
    class func exists(sourceCode: String, targetCode: String, at timestamp: Double, in context: NSManagedObjectContext) -> Bool {
        let result = nil != ldm_findFirst(with: exactPredicate(sourceCode: sourceCode, targetCode: targetCode, at: timestamp), in: context)
        return result
    }
    
    public class func check(sourceCode: String, sourceValue: Double, targetCode: String, at timestamp: Double, in context: NSManagedObjectContext) throws -> Void {
        _ = try validatedTransaction(sourceCode: sourceCode, sourceValue: sourceValue, targetCode: targetCode, at: timestamp, in: context)
    }
    
    class func validatedTransaction(sourceCode: String, sourceValue: Double, targetCode: String, at timestamp: Double, in context: NSManagedObjectContext) throws -> (Money, Money, Quotable) {
        // check that cash for each currency exist?
        guard let fromCash = Money.ldm_findFirst(with: Money.currencyPredicate(currency: sourceCode), in: context) else {
            throw Errors.entryDoesNotExist(sourceCode).error
        }
        
        guard let toCash = Money.ldm_findFirst(with: Money.currencyPredicate(currency: targetCode), in: context) else {
            throw Errors.entryDoesNotExist(targetCode).error
        }
        
        // check timestamp if needed.
        guard let quote = Quote.virtualFind(source: sourceCode, target: targetCode, context: context) else {
            // entry doesn't exists?
            throw SourcesAndTargetsProtocol.Errors.invalidPair(sourceCode, targetCode).error
        }
        
        // check time if we want.
        // we can't make stalled exchanges (transactions).
        guard checkTimestamps(created: timestamp, modified: quote.timestamp) else {
            // throw something?
            throw Errors.transactionsError(sourceCode, targetCode, timestamp, quote.timestamp).error
        }
        
        // add new exchange?
        // check if previous exchange exists?
        guard !exists(sourceCode: sourceCode, targetCode: targetCode, at: timestamp, in: context) else {
            // collision?
            throw Errors.collisionError(sourceCode, targetCode, timestamp).error
        }
        
        // check that we have enough money
        guard fromCash.value >= sourceValue else {
            throw Errors.insufficientBalance(sourceCode, targetCode).error
        }
        return (fromCash, toCash, quote)
    }
}

//MARK: Transaction.
extension Exchange {
    public class func exchange(sourceCode: String, sourceValue: Double, targetCode: String, at timestamp: Double, in context: NSManagedObjectContext) throws {
        let (fromCash, toCash, quote) = try validatedTransaction(sourceCode: sourceCode, sourceValue: sourceValue, targetCode: targetCode, at: timestamp, in: context)
        try saveTransaction(source: fromCash, sourceValue: sourceValue, target: toCash, at: timestamp, byQuote: quote, in: context)
    }
    class func saveTransaction(source: Money, sourceValue: Double, target: Money, at timestamp: Double, byQuote quote: Quotable, in context: NSManagedObjectContext) throws {
        let fromCash = source
        let toCash = target
        let sourceCode = source.currency ?? ""
        let targetCode = target.currency ?? ""
        
        // euros to dollars.
        // 10 euros -> x dollars
        // quote: 1 euro = some dollars.
        // result is:
        // sourceValue = - 10 euros
        // targetValue = + 10 euros * ( some dollars per 1 euro ) = 10 * some dollars = sourceValue * quote.quote
        let targetValue = sourceValue * quote.quote

        // check that operation could be done
        guard fromCash.value >= sourceValue else {
            throw Errors.insufficientBalance(sourceCode, targetCode).error
        }

        let exchange = ldm_create(in: context)
        exchange.timestamp = timestamp
        exchange.sourceCode = sourceCode
        exchange.targetCode = targetCode
        exchange.sourceValue = sourceValue
        exchange.targetValue = targetValue

        fromCash.value -= sourceValue
        toCash.value += targetValue
    }
}
