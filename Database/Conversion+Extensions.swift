//
//  Conversion+Extensions.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//
import CoreData
import Foundation
extension Conversion : SourcesAndTargetsProtocol {
    static func find(source: String, target: String, context: NSManagedObjectContext) -> NSManagedObject? {
        // asks database about pair
        return Conversion.ldm_findFirst(with: sourceAndTargetPredicate(source:source, target:target), in:context)
    }
}

extension Conversion {
    public class func insert(source: String, target: String, context: NSManagedObjectContext) throws {
        let valid = try validPair(source: source, target: target)
        let notExists = try notExistsPair(source: source, target: target, context: context)
        if valid && notExists {
            // add to database
            let conversion = Conversion(context: context)
            conversion.addedAt = Date().timeIntervalSince1970
            conversion.sourceCode = source
            conversion.targetCode = target
        }
    }
    public class func delete(source: String, target: String, context:NSManagedObjectContext) throws {
        if let found = find(source: source, target: target, context: context) {
            _ = found.ldm_deleteEntity(in: context)
        }
    }
}

extension Conversion {
    public var quote: Quotable? {
        guard let context = managedObjectContext, let source = sourceCode, let target = targetCode else {
            return nil
        }
        return Quote.virtualFind(source: source, target: target, context: context)
    }
}
