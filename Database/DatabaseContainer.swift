//
//  DatabaseContainer.swift
//  SwiftTrader
//
//  Created by Dmitry on 09.03.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import CoreData
import EncryptedCoreData

public protocol DatabaseContainerProtocol {
    func checkStack() -> Bool
    func viewContext() -> NSManagedObjectContext?
    func save(block:@escaping ((NSManagedObjectContext?) -> Void), completion: ((Bool, Error?) -> Void)?)
    func setupStack()
    func cleanupStack()
}

internal protocol DatabaseContainerWithEncryptionProtocol {
    func getKey(url: URL) -> String
}

public class DatabaseContainer: DatabaseContainerProtocol {
    init() {
    }
    
    public func checkStack() -> Bool {
        return false
    }
    
    public func viewContext() -> NSManagedObjectContext? {
        return nil
    }

    public func save(block:@escaping ((NSManagedObjectContext?) -> Void), completion: ((Bool, Error?) -> Void)?) {
        guard checkStack() else {
            return
        }
        performBackgroundTask { (backgroundContext) in
            do {
                try autoreleasepool {
                    block(backgroundContext)
                    //        DatabaseSupplement.save(block: block, context: theContext, completion: completion)
                    try backgroundContext.save()
                    completion?(true, nil)
                }
            }
            catch let error {
                completion?(false, error)
            }
        }
    }
    
    public func setupStack() {}
    public func cleanupStack() {}
    public class func container() -> DatabaseContainerProtocol? {
        if #available(iOS 10, *) {
            return DatabaseContainerModern_Encryption()//DatabaseContainerModern()
        }
        return DatabaseContainerPrior10_Encryption()
    }
    
    // Protected
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Swift.Void) {
        
    }
}

extension DatabaseContainer {
    func getBundle() -> Bundle? {
        return Bundle(for: DatabaseContainer.self)
    }
    func getLibraryDirectoryUrl() -> URL? {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return urls.count > 0 ? urls[urls.count - 1] : nil
    }

    func getDatabaseName() -> String? {
        return getBundle()?.infoDictionary?[kCFBundleNameKey as String] as? String
    }

    func getDatabaseExtension() -> String? {
        return "sqlite"
    }
    func getDatabaseUrl() -> URL? {
        guard let url = self.getLibraryDirectoryUrl(), let databaseName = getDatabaseName(), let databaseExtension = getDatabaseExtension() else {
            return nil
        }
        
        return url.appendingPathComponent(databaseName).appendingPathExtension(databaseExtension)
    }
    
    
    func getManagedObjectModel() -> NSManagedObjectModel? {
        guard let url = getBundle()?.url(forResource: "Database", withExtension: "momd") else {
            return nil
        }
        return NSManagedObjectModel(at: url)
    }
}

@available(iOS 10, *)
class DatabaseContainerModern: DatabaseContainer {
    public override func checkStack() -> Bool {
        return accidentError == nil && container != nil
    }
    
    override func viewContext() -> NSManagedObjectContext? {
        return container?.viewContext
    }
    
    public override func setupStack() {
        container = getPersistentStoreContainer()
    }
    
    public override func cleanupStack() {
        container = nil
    }
    
    var accidentError: Error?
    var container: NSPersistentContainer?
    func getPersistentStoreContainer() -> NSPersistentContainer? {
        guard let databaseName = getDatabaseName() else {
            return nil
        }
        
        guard let model = getManagedObjectModel() else {
            return nil
        }
        
        guard let databaseUrl = getDatabaseUrl() else {
            return nil
        }
        
        return getPersistentStoreContainer(databaseName: databaseName, databaseURL: databaseUrl, model: model)
    }
    
    func getPersistentStoreContainer(databaseName: String, databaseURL: URL, model: NSManagedObjectModel) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: databaseName, managedObjectModel: model)
        
        container.persistentStoreDescriptions = persistentStores(at: [databaseURL], names: [databaseName])
        container.loadPersistentStores(completionHandler: {
            [unowned self]
            (description, error) in
            self.accidentError = error
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
    
    func persistentStores(at urls: [URL], names: [String]) -> [NSPersistentStoreDescription] {
        return urls.map { NSPersistentStoreDescription(url: $0) }
    }
    
    override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container?.performBackgroundTask(block)
    }
}

class DatabaseContainerModern_Encryption: DatabaseContainerModern {
    func persistentStore(at url: URL, name: String) -> NSPersistentStoreDescription? {
        let configuration = EncryptedStoreFileManagerConfiguration()
        configuration.databaseURL = url
        configuration.databaseName = name
        configuration.bundle = getBundle()
        var options = [
            EncryptedStore.optionPassphraseKey() : getKey(url: url),
            ] as [String : Any]
        
        if let fileManager = EncryptedStoreFileManager(configuration: configuration) {
            options[EncryptedStore.optionFileManager()] = fileManager
        }
        
        return try? EncryptedStore.makeDescription(options: options, configuration: nil)
    }
    
    override func persistentStores(at urls: [URL], names: [String]) -> [NSPersistentStoreDescription] {
        return urls.compactMap {
            persistentStore(at: $0, name: names.first!)
        }
    }
}

extension DatabaseContainerModern_Encryption : DatabaseContainerWithEncryptionProtocol {
    func getKey(url: URL) -> String {
        return "123123123"
    }
}

class DatabaseContainerPrior10: DatabaseContainer {
    public override func checkStack() -> Bool {
        return accidentError == nil && self.coordinator != nil
    }
    
    override func viewContext() -> NSManagedObjectContext? {
        return mainContext
    }
    
    public override func setupStack() {
        coordinator = getPersistentStoreCoordinator()
        mainContext = getMainContext()
    }
    
    public override func cleanupStack() {
        coordinator = nil
        mainContext = nil
    }
    
    var accidentError: Error?
    var coordinator: NSPersistentStoreCoordinator?
    var mainContext: NSManagedObjectContext?
    //MARK: Old setup
    func getPersistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        guard let managedObjectModel = self.getManagedObjectModel() else {
            return nil
        }
        
        guard let databaseUrl = self.getDatabaseUrl() else {
            return nil
        }
        return getPersistentStoreCoordinator(url: databaseUrl, model: managedObjectModel)
    }
    
    func getPersistentStoreCoordinator(url: URL, model: NSManagedObjectModel) -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:
            model)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true,                                                                                                                    NSInferMappingModelAutomaticallyOption: true])
        }
        catch let error {
            accidentError = error
        }
        
        return coordinator
    }
    
    func getMainContext() -> NSManagedObjectContext? {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.coordinator
        return context
    }
    
    func getBackgroundContext() -> NSManagedObjectContext? {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.viewContext()
        return context
    }
    
    override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Swift.Void) {
        guard let context = self.getBackgroundContext() else {
            return
        }
        
        context.perform {
            block(context)
        }
    }
}

class DatabaseContainerPrior10_Encryption: DatabaseContainerPrior10 {
    override func getPersistentStoreCoordinator(url: URL, model: NSManagedObjectModel) -> NSPersistentStoreCoordinator {
        let configuration = EncryptedStoreFileManagerConfiguration()
        configuration.databaseURL = url
        configuration.bundle = getBundle()
        var options = [
            EncryptedStore.optionPassphraseKey() : getKey(url: url),
            ] as [String : Any]
        
        if let fileManager = EncryptedStoreFileManager(configuration: configuration) {
            options[EncryptedStore.optionFileManager()] = fileManager
        }

        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(ofType: EncryptedStore.optionType()!, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true,                                                                                                                    NSInferMappingModelAutomaticallyOption: true])
        }
        catch let error {
            accidentError = error
        }
        
        return coordinator
    }
}

extension DatabaseContainerPrior10_Encryption : DatabaseContainerWithEncryptionProtocol {
    func getKey(url: URL) -> String {
        return "123123123"
    }
}
