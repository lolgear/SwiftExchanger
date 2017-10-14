//
//  NetworkConfiguration.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
// http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml
public struct Configuration {
    public var serverAddress = "http://www.ecb.europa.eu/stats"
    public var apiAccessKey = ""
    public init(serverAddress theServerAddress: String, apiAccessKey theApiAccessKey: String) {
        serverAddress = theServerAddress
        apiAccessKey = theApiAccessKey
    }
    public init(apiAccessKey theApiAccessKey: String) {
        apiAccessKey = theApiAccessKey
    }
    public init() {}
}
