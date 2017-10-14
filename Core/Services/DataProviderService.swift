//
//  DataProviderService.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 27.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit

class DataProviderService: BaseService {
    lazy var dataProvider = DataProvider.create()
    override var health: Bool {
        return true
    }
    var timer: Timer?
}

extension DataProviderService {
    override func tearDown() {
        stopTimer()
    }
}

extension DataProviderService {
    var updateTimeInterval: TimeInterval { return ApplicationSettingsStorage.loaded().updateTime }
    var backgroundFetchEnabled: Bool { return ApplicationSettingsStorage.loaded().backgroundFetch }
    func startTimer() {
        guard timer == nil else {
            LoggingService.logVerbose("timer already started!")
            return
        }
        
        LoggingService.logVerbose("timer started with interval(\(String(describing: DateComponentsFormatters.stringFromTimeInterval(interval: updateTimeInterval))))")
        timer = Timer.scheduledTimer(withTimeInterval: updateTimeInterval, repeats: true) {
            [unowned self]
            (timer) in
            LoggingService.logVerbose("timer fired! updating quotes!")
            self.dataProvider.updateQuotes()
        }
    }
    func stopTimer() {
        LoggingService.logVerbose("timer invalidated!")
        timer?.invalidate()
        timer = nil
    }
}

extension DataProviderService {
    func updateQuotes() {
        self.dataProvider.updateQuotes {
            (result, error) in
            // log something?
            LoggingService.logVerbose("\(self) \(#function) fetch something? \(result) error: \(error)")
        }
    }
    //what? escaping without optionals?
    func updateQuotes(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.dataProvider.updateQuotes { (result, error) in
            if result {
                completionHandler(.newData)
            }
            else {
                completionHandler(.noData)
            }
        }
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LoggingService.logVerbose("\(self) \(#function) perform background fetch!")
        
        guard backgroundFetchEnabled else {
            LoggingService.logVerbose("\(self) \(#function) background fetch disabled!")
            return
        }
        updateQuotes(completionHandler: completionHandler)
    }
    func applicationWillTerminate(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) stop timer!")
        stopTimer()
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) start timer!")
        // DEBUG
        updateQuotes()
        // fetch here for now
        // DEBUG
        startTimer()
    }
    func applicationWillResignActive(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) stop timer!")
        stopTimer()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) stop timer!")
        stopTimer()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) start timer!")
        startTimer()
    }
}
