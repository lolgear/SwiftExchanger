//
//  NSManagedObject+Extensions.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 27.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord
//MARK: find
extension NSManagedObject {
    open class func ldm_findFirst(with searchTerm: NSPredicate, in context: NSManagedObjectContext) -> Self? {
        return mr_findFirst(with: searchTerm, in: context)
    }
    
    open class func ldm_findAll(in context: NSManagedObjectContext) -> [Any] {
        return mr_findAll(in: context)
    }
}

//MARK: fetch
extension NSManagedObject {
    open class func ldm_fetchAllSorted(by sortTerm: String, ascending: Bool, with searchTerm: NSPredicate?, groupBy groupingKeyPath: String?, delegate: NSFetchedResultsControllerDelegate?, context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {        
        return mr_fetchAllSorted(by: sortTerm, ascending: ascending, with: searchTerm, groupBy: groupingKeyPath, delegate:delegate, in: context)
    }
}

//MARK: create
extension NSManagedObject {
    open class func ldm_findFirstOrCreate(byAttribute attribute: String, withValue value: Any, in context: NSManagedObjectContext) -> Self {
        return mr_findFirstOrCreate(byAttribute: attribute, withValue: value, in: context)
    }
    open class func ldm_create(in context: NSManagedObjectContext) -> Self {
        return mr_createEntity(in: context)
    }
}

//MARK: delete
extension NSManagedObject {
    open func ldm_deleteEntity(in context: NSManagedObjectContext) -> Bool {
        return mr_deleteEntity(in: context)
    }
    open class func ldm_deleteAll(predicate: NSPredicate?, in context: NSManagedObjectContext) {
        let thePredicate = predicate ?? NSPredicate(value: true)
        mr_deleteAll(matching: thePredicate, in: context)
    }
}
