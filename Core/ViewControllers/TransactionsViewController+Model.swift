//
//  TransactionsViewController+Model.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import CoreData
import DatabaseBeaver
@objc protocol TransactionsViewControllerModelObservingProtocol {
    func didUpdateModel()
}

extension TransactionsViewController {
    class Model: NSObject {
        private(set) var exchanges: NSFetchedResultsController<Exchange>?
        weak var observingDelegate: TransactionsViewControllerModelObservingProtocol?
    }
}

//MARK: Table-driven methods
extension TransactionsViewController.Model {
    func numberOfSections() -> Int {
        return self.exchanges?.sections?.count ?? 0
    }
    func numberOfObjects(in section: Int) -> Int {
        return self.exchanges?.sections?[section].numberOfObjects ?? 0
    }
    func objectAtIndexPath(indexPath: IndexPath) -> Exchange? {
        guard let object = self.exchanges?.sections?[indexPath.section].objects?[indexPath.row] as? Exchange else {
            return nil
        }
        return object
    }
}

//MARK: Configuration
extension TransactionsViewController.Model {
    func configured(by exchanges: NSFetchedResultsController<Exchange>?) -> Self {
        self.exchanges = exchanges
        self.exchanges?.delegate = self
        return self
    }
}

//MARK: Observation
extension TransactionsViewController.Model: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let name = controller.fetchRequest.entityName else {
            return
        }
        
        switch name {
        case Exchange.mr_entityName():
            // reload data?
            self.observingDelegate?.didUpdateModel()
        default: return
        }
    }
}
