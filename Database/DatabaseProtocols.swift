//
//  DatabaseProtocols.swift
//  SwiftTrader
//
//  Created by Dmitry on 09.03.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData

protocol SourcesAndTargetsProtocol {
    static func find(source: String, target: String, context: NSManagedObjectContext) -> NSManagedObject?
}
//MARK: Pair validation
extension SourcesAndTargetsProtocol {
    static func validPair(source: String, target: String) throws -> Bool {
        guard source != target else {
            throw Errors.invalidPair(source, target).error
        }
        return true
    }
    
    static func notExistsPair(source: String, target: String, context: NSManagedObjectContext) throws -> Bool {
        guard find(source: source, target: target, context: context) == nil else {
            throw Errors.pairExists(source, target).error
        }
        return true
    }
}
//MARK: Errors
extension SourcesAndTargetsProtocol {
    typealias Errors = SourcesAndTargetsProtocolErrors
}

//MARK: Predicates
extension SourcesAndTargetsProtocol {
    static func sourcePredicate(value: String) -> NSPredicate {
        let sourcePredicate = NSPredicate(format: "sourceCode = %@", argumentArray: [value])
        return sourcePredicate
    }
    
    static func targetPredicate(value: String) -> NSPredicate {
        let targetPredicate = NSPredicate(format: "targetCode = %@", argumentArray: [value])
        return targetPredicate
    }
    
    // For source in target conversion.
    static func sourceAndTargetPredicate(source: String, target: String) -> NSPredicate {
        let left = sourcePredicate(value: source)
        let right = targetPredicate(value: target)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [left, right])
    }
}
