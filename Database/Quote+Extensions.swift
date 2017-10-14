//
//  Quote+Extensions.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData
public protocol Quotable {
    var quote: Double {get}
    var previousQuote: Double {get}
    var trend: Double {get}
    var timestamp: Double {get}
    var sourceCode: String? {get}
    var targetCode: String? {get}
}
public extension Quotable {
    public var trend: Double {
        return self.previousQuote == 0 ? 0 : self.quote - self.previousQuote
    }
}
public struct VirtualQuote: Quotable {
    public var quote: Double
    public var previousQuote: Double
    public var timestamp: Double

    public var sourceCode: String?
    public var targetCode: String?
    public static func oneToOneQuote(sourceCode: String?) -> Quotable {
        return VirtualQuote(quote: 1, previousQuote: 1, timestamp: 0, sourceCode: sourceCode, targetCode: sourceCode)
    }
}
extension Quote : Quotable {}
extension Quote : SourcesAndTargetsProtocol {
    static func find(source: String, target: String, context: NSManagedObjectContext) -> NSManagedObject? {
        return ldm_findFirst(with: sourceAndTargetPredicate(source: source, target: target), in: context)
    }
    public static func virtualFind(source: String, target: String, context: NSManagedObjectContext) -> Quotable? {
        if virtual(source: source, target: target) {
            // create in context?
            // find correct items
            
            /*
                | B | S | T |
             ------------------
              B | 1 | X | Y |
             ------------------
              S |1/X| 1 |Y/X|
             ------------------
              T |1/Y|X/Y| 1 |
             ------------------
             */
            let S = find(source: baseCode, target: source, context: context)
            let T = find(source: baseCode, target: target, context: context)
            // now we have X and Y
            guard let sourceQuote = S as? Quote, let targetQuote = T as? Quote else {
                return nil
            }
            
            let X = sourceQuote.quote
            let Y = targetQuote.quote
            
            let prevX = sourceQuote.previousQuote
            let prevY = targetQuote.previousQuote
                        
            let correctQuote = Y / X
            let correctPreviousQuote = prevX == 0 ? 0 : prevY / prevX
            
            let timestamp = targetQuote.timestamp
            
            let virtualQuote = VirtualQuote(quote: correctQuote, previousQuote: correctPreviousQuote, timestamp: timestamp, sourceCode: source, targetCode: target)
            return virtualQuote
        }
        else {
            // fetch
            return find(source: source, target: target, context: context) as? Quote
        }
    }

}

extension Quote {
    class var baseCode : String {
        return DatabaseSettings.baseCode
    }
    
    // update quote?
    func firstUpdate() -> Bool {
        return timestamp == 0
    }
    
    func update(quote: Double, at timestamp: Double) {
        guard self.timestamp != timestamp else {
            return
        }
        
        if firstUpdate() {
            self.quote = quote
        }
        else {
            //TODO: fix later.
            //Known bug: bad access.
            self.previousQuote = self.quote
            self.quote = quote
        }
        
        self.timestamp = timestamp
    }
    
    class func update(source: String, target: String, quote: Double, at timestamp: Double, context: NSManagedObjectContext) {
        if !virtual(source: source, target: target) {
            if let q = find(source: source, target: target, context: context) as? Quote {
                q.update(quote: quote, at: timestamp)
            }
        }
    }

    class func virtual(source: String, target: String) -> Bool {
        return source != baseCode && target != baseCode
    }
    
    class func insert(source: String, target: String, quote: Double, timestamp: Double, context: NSManagedObjectContext) throws {
        let notVirtual = !virtual(source: source, target: target)
        let notExists = try notExistsPair(source: source, target: target, context: context)
        let valid = try validPair(source: source, target: target)
        if notVirtual && notExists && valid {
            let q = Quote(context: context)
            q.sourceCode = source
            q.targetCode = target
            q.update(quote: quote, at: timestamp)
        }
    }
    
    public class func upsert(source: String, target: String, quote: Double, timestamp: Double, context: NSManagedObjectContext) {
        if let q = find(source: source, target: target, context: context) as? Quote {
            q.update(quote: quote, at: timestamp)
        }
        else {
            try? insert(source: source, target: target, quote: quote, timestamp: timestamp, context: context)
        }
    }
}

extension Quote {
    static func aggregated(theCurrencies: [Any]?) -> [String] {
        
        guard let currencies = theCurrencies else {
            return []
        }
        
        let all = currencies.filter{($0 as! Quote).targetCode != nil}.map {($0 as! Quote).targetCode!}
        if all.isEmpty || baseCode.isEmpty {
            return []
        }
        var result = all
        result.append(baseCode)
        return result
    }
    
    static func currencies(context: NSManagedObjectContext) -> [String] {
        let all = Quote.ldm_findAll(in: context)
        return aggregated(theCurrencies: all)
    }    
}
