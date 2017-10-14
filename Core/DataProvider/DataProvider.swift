//
//  DataProvider.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import DatabaseBeaver
import NetworkWorm
class DataProvider {
    func updateQuotes(completion: ((Bool,Error?) -> Void)? = nil) {
        let network = ServicesManager.manager.networkService
        let database = ServicesManager.manager.databaseService
        // configure command and send it
        let command = DailyQuotesCommand()
        network?.client.executeCommand(command: command, onResponse: { response in
            // try to save it to database
            if let errorResponse = response as? ErrorResponse {
                completion?(false, errorResponse.descriptiveError)
                return
            }
            
            guard let currentResponse = response as? DailyQuotesResponse else {
                completion?(false, ErrorFactory.createError(errorType: .unknown))
                return
            }
            
            let source = currentResponse.source
            let timestamp = currentResponse.timestamp
            LoggingService.logInfo("\(self) \(#function) timestamp: \(timestamp)")
            // database will save
            database?.baseCode = currentResponse.source
            // save in block?
            database?.save(block: { (context) in
                for quote in currentResponse.quotes {
                    Quote.upsert(source: source, target: quote.key, quote: quote.value, timestamp: timestamp, context: context!)
                }
            }, completion: completion)
        })
    }
    
    func addConversion(source: String, target: String, onError: ((Error?) -> ())?, completion: ((Bool,Error?) -> Void)? = nil) {
        let database = ServicesManager.manager.service(name: DatabaseService.name) as? DatabaseService
        database?.save(block: { (context) in
            do {
                try database?.insert(source: source, target: target, context: context!)
            }
            catch let error {
                onError?(error)
            }
        }, completion: completion)
    }
    
    func removeConversion(source: String, target: String, onError: ((Error?) -> Void)?, completion: ((Bool,Error?) -> Void)? = nil) {
        let database = ServicesManager.manager.service(name: DatabaseService.name) as? DatabaseService
        database?.save(block: { (context) in
            do {
                try database?.delete(source: source, target: target, context: context!)
            }
            catch let error {
                onError?(error)
            }
        }, completion: completion)
    }
    
    class func create() -> DataProvider {
        return DebugDataProvider()
    }
}

class DebugDataProvider: DataProvider {
    override func updateQuotes(completion: ((Bool, Error?) -> Void)?) {
        let theCompletion: (Bool,Error?) -> Void = {
            (result, error) in
            completion?(result, error)
            if let currentError = error {
                LoggingService.logError("\(self) \(#function) error: \(currentError.localizedDescription)")
            }
            else {
                LoggingService.logInfo("\(self) \(#function) result: \(result)")
            }
        }
        super.updateQuotes(completion: theCompletion)
    }
    override func addConversion(source: String, target: String, onError: ((Error?) -> ())?, completion: ((Bool, Error?) -> Void)?) {
        let theOnError: (Error?) -> () = {
            (error) in
            onError?(error)
            if let currentError = error {
                LoggingService.logError("\(self) \(#function) error: \(currentError.localizedDescription)")
            }
        }
        let theCompletion: (Bool, Error?) -> Void = {
            (result, error) in
            completion?(result, error)
            if let currentError = error {
                LoggingService.logError("\(self) \(#function) error: \(currentError.localizedDescription)")
            }
            else {
                LoggingService.logInfo("\(self) \(#function) result: \(result)")
            }
        }
        super.addConversion(source: source, target: target, onError: theOnError, completion: theCompletion)
    }
    override func removeConversion(source: String, target: String, onError: ((Error?) -> Void)?, completion: ((Bool, Error?) -> Void)?) {
        let theOnError: (Error?) -> () = {
            (error) in
            onError?(error)
            if let currentError = error {
                LoggingService.logError("\(self) \(#function) error: \(currentError.localizedDescription)")
            }
        }
        let theCompletion: (Bool, Error?) -> Void = {
            (result, error) in
            completion?(result, error)
            if let currentError = error {
                LoggingService.logError("\(self) \(#function) error: \(currentError.localizedDescription)")
            }
            else {
                LoggingService.logInfo("\(self) \(#function) result: \(result)")
            }
        }
        super.removeConversion(source: source, target: target, onError: theOnError, completion: theCompletion)
    }
}
