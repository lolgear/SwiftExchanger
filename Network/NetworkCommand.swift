//
//  NetworkCommand.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//
import Alamofire
import Foundation
public class Command {
    
    public init() {}
    
    var shouldStopError: Error?
    
    var shouldStop: Bool {
        return shouldStopMessage != nil
    }
    
    var shouldStopMessage: String? {
        return shouldStopError?.localizedDescription
    }

    var configuration: Configuration? // assign somewhere before use.
    
    //MARK: Subclass
    var method: Alamofire.HTTPMethod = .get
    var path = ""
    var authorized = true
    func queryParameters() -> [String : AnyObject]? {
        return [:]
    }
}

// Endpoint : { /list }
// Params : {
//    "access_key" : "YOUR_ACCESS_KEY"
// }
public class APICommand: Command {
    override func queryParameters() -> [String : AnyObject]? {
        var result = super.queryParameters()
        guard configuration != nil else {
            shouldStopError = ErrorFactory.createError(errorType: .theInternal("Configuration did not set!" as AnyObject?))
            return result
        }
        result?["access_key"] = configuration?.apiAccessKey as AnyObject?
        return result
    }
}
public class DailyQuotesCommand: APICommand {
    public override init() {
        super.init()
        path = "eurofxref/eurofxref-daily.xml"
    }
}
public class ListCurrenciesCommand: APICommand {
    public override init() {
        super.init()
        path = "list"
    }
}
public class LiveRatesCommand: APICommand {
    public override init() {
        super.init()
        path = "live"
    }
}
public class HistoricalRatesCommand: APICommand {
    public override init() {
        super.init()
        path = "historical"
    }
}
