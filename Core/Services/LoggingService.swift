//
//  LoggingService.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 27.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CocoaLumberjack
class DateComponentsFormatters {
    class func stringFromTimeInterval(interval: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day]
        formatter.zeroFormattingBehavior = .pad;
        let string = formatter.string(from: interval)
        return string
    }
}

class CustomLogFormatter: NSObject, DDLogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        var logMark: String = ""
        switch logMessage.level {
        case .error    : logMark = "(❗️) Error"
        case .warning  : logMark = "(❓) Warning"
        case .info     : logMark = "(💧) Info"
        case .debug    : logMark = "(✅) Debug"
        default        : logMark = "(🔤) Verbose"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return "\(formatter.string(from: Date())) | \(logMark) | \(logMessage.message)"
    }
}

class LoggingService: BaseService {
    class func log(level: DDLogLevel, message: String) {
        switch level {
        case .error    : DDLogError(message)
        case .warning  : DDLogWarn(message)
        case .info     : DDLogInfo(message)
        case .debug    : DDLogDebug(message)
        case .verbose  : DDLogVerbose(message)
        default: DDLogVerbose(message)
        }
    }
    class func logError(_ message: String) {
        log(level: .error, message: message)
    }
    class func logWarning(_ message: String) {
        log(level: .warning, message: message)
    }
    class func logInfo(_ message: String) {
        log(level: .info, message: message)
    }
    class func logDebug(_ message: String) {
        log(level: .debug, message: message)
    }
    class func logVerbose(_ message: String) {
        log(level: .verbose, message: message)
    }
    class func logAll(_ message: String) {
        log(level: .all, message: message)
    }
}

//MARK: Setup
extension LoggingService {
    func setupGeneralLogging() {
        let logger = DDTTYLogger.sharedInstance
        guard let currentLogger = logger else {
            return
        }

        DDLog.add(currentLogger)
        // format?
        currentLogger.logFormatter = CustomLogFormatter()
    }
}

//MARK: ServicesInfoProtocol
extension LoggingService {
    override var health: Bool {
        return true
    }
}

//MARK: ServicesSetupProtocol
extension LoggingService {
    override func setup() {
        setupGeneralLogging()
    }
}
