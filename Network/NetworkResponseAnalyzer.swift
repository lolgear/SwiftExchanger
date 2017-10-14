//
//  NetworkResponseAnalyzer.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
//import SWXMLHash
import XMLDictionary

protocol ResponseSerializer {
    func deserialize(data: Data) -> Any?
}

class ResponseAnalyzer {
    enum contextKeys: String {
        case reachable
    }
    
    // response result tuple
    typealias ResponseTuple = (AnyObject?, NSError?)
    
    class JSONSerializer: ResponseSerializer {
        func deserialize(data: Data) -> Any? {
            return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
    }
    
    class XMLSerializer: ResponseSerializer {
        func setup () {
            parser.attributesMode = .unprefixed
//            parser.nodeNameMode = .never
        }
        init() {
            setup()
        }
        let parser = XMLDictionaryParser()
        func deserialize(data: Data) -> Any? {
            let item = parser.dictionary(with: data)
            return item
        }
    }
    
    // response serializer
    var serializer: ResponseSerializer = XMLSerializer()
    
    init() {}
}

public extension Dictionary {
    func value<T>(forKeyPath path: String) -> T? {
        let dictionary = self as NSDictionary
        return dictionary.value(forKeyPath: path) as? T
    }
}
//MARK: analyzing
extension ResponseAnalyzer {
    // analyze response
    func analyze(response: [String : AnyObject], context: [String : AnyObject]?) -> Response? {
        guard successful(response: response) else {
            return ErrorResponse(dictionary: response)
        }
        // try to recognize result somehow
        return SuccessResponse(dictionary: response)?.blessed()
    }
    
    func analyze(response: Data?, context:[String : AnyObject]?, error: Error?) -> Response? {
        guard error == nil else {
            return ErrorResponse(error: error!)
        }
        
        guard let theResponse = response else {
            return ErrorResponse(error: ErrorFactory.createError(errorType: .responseIsEmpty)!)
        }
        
        // Dictionary : Dictionary : Array : {time -> value}, {}
//        if let obj = serializer.deserialize(data: theResponse) as? [String : AnyObject] {
//            // here
//            var value: [AnyObject] = []
//            value = obj.value(forKeyPath: "Cube.Cube") ?? []
//            print("")
//        }
        
        guard let responseObject = serializer.deserialize(data: theResponse) as? [String : AnyObject] else {
            return ErrorResponse(error: ErrorFactory.createError(errorType: .couldNotParse(theResponse as AnyObject?))!)
        }
        return self.analyze(response: responseObject, context: context)
    }
    
    func successful(response: [String : AnyObject]?) -> Bool {
        // and it is?
        let test = (response?["gesmes:subject"] as? String) != nil
        return test
    }
}
