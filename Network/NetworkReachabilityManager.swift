//
//  NetworkReachabilityManager.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//
import Alamofire
import Foundation
public class ReachabilityManager {
    public init(targetHost host: String) {
        self.host = host
        self.manager = NetworkReachabilityManager(host: host)
    }
    
    private var manager : NetworkReachabilityManager?
    
    private(set) var host: String {
        didSet{
            self.manager = NetworkReachabilityManager(host: host)
        }
    }
    
    public var reachable: Bool {
        return manager?.isReachable ?? false
    }
    
    public func startMonitoring() {
        self.manager?.startListening()
    }
}
