//
//  ApplicationSettingsStorage.swift
//  SwiftTrader
//
//  Created by Dmitry on 09.03.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
class ApplicationSettingsStorage {
    private var settings: [String : AnyObject] = [:]
    private let storeIdentifier = "ApplicationSettings"
    private enum Attributes {
        case alreadyConfiguredAfterRunAtFirstTime
        case updateTime
        case backgroundFetch
        case networkAPIKey
        
        var identifier: String {
            switch self {
            case .alreadyConfiguredAfterRunAtFirstTime: return "General.AlreadyConfiguredAfterRunAtFirstTimee"
            case .updateTime: return "General.UpdateTime"
            case .backgroundFetch: return "General.BackgroundFetch"
            case .networkAPIKey: return "General.NetworkAPIKey"
            }
        }
    }
    static var ProductionSettings: ApplicationSettingsStorage = {
        let settings = ApplicationSettingsStorage()
        settings.updateTime = 30 //30 seconds
        settings.backgroundFetch = true
        settings.networkAPIKey = ""// f8a9b90bc6525a28e131b47630a60abc
        return settings
    }()
    
    static var DeveloperSettings: ApplicationSettingsStorage = {
        let settings = ApplicationSettingsStorage()
        settings.updateTime = 86400
        settings.backgroundFetch = false
        settings.networkAPIKey = "f8a9b90bc6525a28e131b47630a60abc"
        return settings
    }()
    
    static var DefaultSettings = DeveloperSettings
    
    var alreadyConfiguredAfterRunAtFirstTime: Bool {
        get {
            return settings[Attributes.alreadyConfiguredAfterRunAtFirstTime.identifier] as? Bool ?? false
        }
        set {
            settings[Attributes.alreadyConfiguredAfterRunAtFirstTime.identifier] = newValue as AnyObject
            self.save()
        }
    }
    
    var updateTime: TimeInterval {
        get {
            return settings[Attributes.updateTime.identifier] as? TimeInterval ?? ApplicationSettingsStorage.DefaultSettings.updateTime
        }
        set {
            settings[Attributes.updateTime.identifier] = newValue as AnyObject
        }
    }
    
    var backgroundFetch: Bool {
        get {
            return settings[Attributes.backgroundFetch.identifier] as? Bool ?? ApplicationSettingsStorage.DefaultSettings.backgroundFetch
        }
        set {
            settings[Attributes.backgroundFetch.identifier] = newValue as AnyObject
        }
    }
    
    var networkAPIKey: String {
        get {
            return settings[Attributes.networkAPIKey.identifier] as? String ?? ApplicationSettingsStorage.DefaultSettings.networkAPIKey
        }
        set {
            settings[Attributes.networkAPIKey.identifier] = newValue as AnyObject
        }
    }
    
    func load() {
        if let storedSettings = UserDefaults.standard.dictionary(forKey: storeIdentifier) as [String : AnyObject]? {
            settings = storedSettings
        }
    }
    
    class func loaded() -> ApplicationSettingsStorage {
        let storage = ApplicationSettingsStorage()
        storage.load()
        return storage
    }
    
    func save() {
        // send save configuration event
        // lazy, do it later in correct way.
        UserDefaults.standard.setValue(settings, forKey: storeIdentifier)        
    }
}
