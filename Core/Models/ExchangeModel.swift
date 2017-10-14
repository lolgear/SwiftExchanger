//
//  ExchangeModel.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 07.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import CoreData
import DatabaseBeaver

struct ExchangeModel {
    var sourceCode: String?
    var targetCode: String?
    var sourceValue: Double?
    var targetValue: Double? {
        if let sourceValue = sourceValue, let quoteValue = quoteValue {
            return sourceValue * quoteValue
        }
        return nil
    }
    var quoteValue: Double?
    private var timestamp: Double {
        return Date().timeIntervalSince1970
    }
    enum Errors {
        static let domain = "org.opensource.swift_exchanger.business"
        case sourceCodeIsNil
        case targetCodeIsNil
        case sourceValueIsNil
        var code: Int {
            switch self {
            case .sourceCodeIsNil: return -101
            case .targetCodeIsNil: return -102
            case .sourceValueIsNil: return -103
            }
        }
        var message: String {
            switch self {
            case .sourceCodeIsNil: return "From currency is nil or empty."
            case .targetCodeIsNil: return "To currency is nil or empty."
            case .sourceValueIsNil: return "Exchange amount is empty."
            }
        }
        var error: Error {
            return NSError(domain: type(of: self).domain, code: code, userInfo: [NSLocalizedDescriptionKey : message])
        }
    }
}

extension ExchangeModel {
    // sourceCode, targetCode, sourceValue
    func correctValues() throws -> (String, String, Double) {
        guard let sourceCode = self.sourceCode else {
            throw Errors.sourceCodeIsNil.error
        }
        guard let targetCode = self.targetCode else {
            throw Errors.targetCodeIsNil.error
        }
        guard let sourceValue = self.sourceValue, sourceValue > 0 else {
            throw Errors.sourceValueIsNil.error
        }
        return (sourceCode, targetCode, sourceValue)
    }

    func check(context: NSManagedObjectContext) throws {
        let (sourceCode, targetCode, sourceValue) = try correctValues()
        try Exchange.check(sourceCode: sourceCode, sourceValue: sourceValue, targetCode: targetCode, at: timestamp, in: context)
    }
    
    func save(context: NSManagedObjectContext) throws {
        let (sourceCode, targetCode, sourceValue) = try correctValues()
        try Exchange.exchange(sourceCode: sourceCode, sourceValue: sourceValue, targetCode: targetCode, at: timestamp, in: context)
    }
}
