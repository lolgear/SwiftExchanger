//
//  NSPredicate+Extensions.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 05.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
extension NSPredicate {
    func not() -> NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: self)
    }
}
