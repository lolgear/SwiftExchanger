//
//  NetworkAPIClient.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Alamofire
import Foundation

public class APIClient {
    public init(configuration theConfiguration: Configuration?) {
        configuration = theConfiguration
    }
    
    public func update(configuration theConfiguration: Configuration?) {
        configuration = theConfiguration
        reachabilityManager = ReachabilityManager(targetHost: configuration?.serverAddress ?? "")
    }
    
    public private(set) var configuration: Configuration?
    public var reachabilityManager: ReachabilityManager?
    lazy var analyzer = ResponseAnalyzer()
    
    func URLComponents(strings: String ...) -> String {
        return strings.joined(separator: "/")
    }
    
    func fullURL(path: String) -> String {
        return URLComponents(strings: configuration?.serverAddress ?? "", path)
    }
    
    func executeOperation(method: Alamofire.HTTPMethod, path: String, parameters: [String : AnyObject]?, onResponse: @escaping (Response) -> ()) {
        let url = fullURL(path: path)
//        Alamofire.SessionManager.default.request(url, method: method, parameters: parameters) {
//            ()
//        }
        Alamofire.SessionManager.default.request(url, method: method, parameters: parameters).response { (response) in
            // case class?
            // case class is what?
            let error = response.error
            let data = response.data
            let response = self.analyzer.analyze(response: data, context: nil, error: error) ?? ErrorResponse(error: ErrorFactory.createError(errorType: .unknown)!)
            onResponse(response)
        }
    }
    
    public func executeCommand(command: Command, onResponse: @escaping (Response) -> ()) {
        command.configuration = configuration
        let method = command.method
        let path = command.path
        let parameters = command.queryParameters()
        if let error = command.shouldStopError {
            onResponse(ErrorResponse(error: error))
            return
        }
        executeOperation(method: method, path: path, parameters: parameters, onResponse: onResponse)
    }
}
