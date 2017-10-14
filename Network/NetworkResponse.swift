//
//  NetworkResponse.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation

// Maybe declare as protocol?
public class Response {
    public typealias DictionaryPayloadType = [String : AnyObject]
    var dictionary: DictionaryPayloadType = [:]
    public init?(dictionary: DictionaryPayloadType) {
        self.dictionary = dictionary
    }
}
/*
 "currencies": {
 "AED": "United Arab Emirates Dirham",
 "AFN": "Afghan Afghani",
 "ALL": "Albanian Lek",
 "AMD": "Armenian Dram",
 "ANG": "Netherlands Antillean Guilder",
 [...]
 }
 */
public class SuccessResponse: Response {
    class func blessed(dictionary: DictionaryPayloadType) -> SuccessResponse? {
        // register and determine?
        if let response = DailyQuotesResponse(dictionary: dictionary) {
            return response
        }
        if let response = RatesResponse(dictionary: dictionary) {
            return response
        }
        
        if let response = ListCurrenciesResponse(dictionary: dictionary) {
            return response
        }
        return nil
    }
    
    func blessed() -> SuccessResponse? {
        return SuccessResponse.blessed(dictionary: self.dictionary)
    }
}

public class ListCurrenciesResponse: SuccessResponse {
    var currencies: [String : String] = [:]
    var currenciesCodes: [String] {
        return Array(currencies.keys)
    }
    public override init?(dictionary: DictionaryPayloadType) {
        super.init(dictionary: dictionary)
        if let currencies = dictionary["currencies"] as? [String : String] {
            self.currencies = currencies
        }
        else {
            return nil
        }
    }
}

/*
 "terms": "https://currencylayer.com/terms",
 "privacy": "https://currencylayer.com/privacy",
 "timestamp": 1430401802,
 "source": "USD",
 "quotes": {
 "USDAED": 3.672982,
 "USDAFN": 57.8936,
 "USDALL": 126.1652,
 "USDAMD": 475.306,
 "USDANG": 1.78952,
 "USDAOA": 109.216875,
 "USDARS": 8.901966,
 "USDAUD": 1.269072,
 "USDAWG": 1.792375,
 "USDAZN": 1.04945,
 "USDBAM": 1.757305,
 [...]
 }
 */

// Quotes are String -> Double
public class RatesResponse : SuccessResponse {
    public var timestamp : Double = 0
    public var source : String = ""
    var dirtyQuotes : [String : Double] = [:]
    public var quotes : [String : Double] {
        return dictionaryByRemovingPrefix(prefix: source, dictionary: dirtyQuotes)
    }
    public override init?(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        if let timestamp = dictionary["timestamp"] as? Double, let source = dictionary["source"] as? String, let quotes = dictionary["quotes"] as? [String : Double]
        {
            self.timestamp = timestamp
            self.source = source
            self.dirtyQuotes = quotes
        }
        else {
            return nil
        }
    }
}

extension RatesResponse {
    func stringByRemovingPrefix(prefix: String, fromString original: String) -> String {
        guard let range = original.range(of: prefix) else {
            return original
        }
        var removing = original
        removing.removeSubrange(range)
        return removing
    }
    
    func dictionaryByRemovingPrefix(prefix: String, dictionary: [String : Double]) -> [String : Double] {
        return dictionary.map {($0, $1)}.map{
            (stringByRemovingPrefix(prefix: prefix, fromString: $0.0), $0.1)
            }.reduce([:], { (result, tuple) -> [String : Double] in
                var updated = result
                updated[tuple.0] = tuple.1
                return updated
            })
    }
}


/*
 {
 "success": false,
 "error": {
 "code": 104,
 "info": "Your monthly usage limit has been reached. Please upgrade your subscription plan."
 }
 }
 */

/*
 
 */
public class DailyQuotesResponse : SuccessResponse {
    public var timestamp: Double = 0
    public var source = "EUR"
    public var quotes: [String: Double] = [:]
    
    public override init?(dictionary: DictionaryPayloadType) {
        super.init(dictionary: dictionary)
        if let timestamp = extractTimeStamp(dictionary: dictionary), let quotes = extractCurrencies(dictionary: dictionary) {
            // convert time into something?
            // do something
            self.timestamp = timestamp
            self.quotes = quotes
        }
        else {
            return nil
        }
    }
}

// MARK: Extraction
extension DailyQuotesResponse {
    static var defaultDateTimeFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        return formatter
    }()
    class func timestampFromDateString(dateString: String) -> Double? {
        let formatter = defaultDateTimeFormatter
        guard let date = formatter.date(from: dateString) else {
            return nil
        }
        return date.timeIntervalSince1970 as Double
    }
    func cubeItems(dictionary: DictionaryPayloadType) -> [String : AnyObject]? {
        return ((dictionary["Cube"] as? [String : AnyObject])?["Cube"]) as? [String : AnyObject]
    }
    // timestamp
    func extractTimeStamp(dictionary: DictionaryPayloadType) -> Double? {
        guard let cubeItems = cubeItems(dictionary: dictionary) else {
            return nil
        }
        
        guard let dateString = cubeItems["time"] as? String else {
            return nil
        }
        
        return type(of: self).timestampFromDateString(dateString: dateString)
    }
    
    // USD : 1
    func extractCurrencies(dictionary: DictionaryPayloadType) -> [String : Double]? {
        guard let cubeItems = cubeItems(dictionary: dictionary) else {
            return nil
        }
        
        guard let currencies = cubeItems["Cube"] as? [[String: AnyObject]] else {
            return nil
        }
        let result = currencies.flatMap { (dictionary) -> (String, Double)? in
            guard let currency = dictionary["currency"] as? String, let rateString = dictionary["rate"] as? String, let rate = Double(rateString) else {
                return nil
            }
            return (currency, rate)
            }
            .reduce([:]) { (dictionary, value) -> [String : Double] in
                var updated = dictionary
                updated[value.0] = value.1
                return updated
        }
        return result
    }
}

public class ErrorResponse : Response {
    var code: Int = 0
    var info = ""
    var error: Error?
    public var descriptiveError : Error? {
        return error ?? NSError(domain: ErrorFactory.Errors.domain, code: code, userInfo: [NSLocalizedDescriptionKey : info])
    }
    public init(error: Error) {
        super.init(dictionary: [:])!
        self.error = error
    }
    
    public override init?(dictionary: DictionaryPayloadType) {
        super.init(dictionary: dictionary)
        
        guard dictionary["success"] as? Bool == false else {
            return nil
        }
        
        guard let error = dictionary["error"] as? [String : AnyObject] else {
            return nil
        }
        
        if let code = error["code"] as? Int, let info = error["info"] as? String {
            self.code = code
            self.info = info
        }
        else {
            return nil
        }
    }
}
