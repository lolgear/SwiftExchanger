//
//  NetworkErrorFactory.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
public class ErrorFactory {
    public enum Errors {
        public static let domain = "org.opensource.network.swift_exchanger"
        case couldNotConnectToServer
        case responseIsEmpty        
        case unknown
        case couldNotParse(AnyObject?)
        case theInternal(AnyObject?)
        var code : Int {
            switch self {
            case .couldNotConnectToServer: return -100
            case .responseIsEmpty: return -101
            case .unknown: return -102
            case .couldNotParse(_): return -103
            case .theInternal: return -104
            }
        }
        var message : String {
            switch self {
            case .couldNotConnectToServer: return "could not connect to server!"
            case .responseIsEmpty: return "aware! response is empty!"
            case .unknown: return "something wrong? unknown"
            case let .couldNotParse(item): return "could not parse item: \(String(describing: item))"
            case let .theInternal(item): return "internal error: \(String(describing: item))"
            }
        }
    }

    // MARK: Init
    public required init() {}
}

// MARK: Create errors
extension ErrorFactory {
    public class func createError(errorType type:Errors) -> Error? {
        return self.init().createError(message: type.message, code: type.code)
    }
    
    func createError(message: String?, code: Int) -> Error? {
        guard let description = message else {
            return nil
        }
        let error = NSError(domain: Errors.domain, code: code, userInfo: [NSLocalizedDescriptionKey : description])
        return createError(error: error as Error)
    }
    
    func createError(error: Error?) -> Error? {
        guard let theError = error else {
            return nil
        }
        return customizeError(error: theError)
    }
}

// MARK: Subclass
extension ErrorFactory {
    func customizeError(error: Error) -> Error {
        return error
    }
}
