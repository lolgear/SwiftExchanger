//
//  MoneyListViewController+Model.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 11.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import CoreData
import DatabaseBeaver

@objc protocol MoneyListViewControllerModelObservingProtocol {
    func didUpdateMoney(current: Money?)
    func didUpdateCurrency(currency: String?)
    func didUpdateValue(value: Double)
}

@objc protocol MoneyListViewControllerModelProtocol {
    func didSelectCurrency(current: String?)
}

extension MoneyListViewController {
    class Model: NSObject {
        enum Identifier: String {
            case source
            case target
            var sign: MoneyViewController.Model.Sign {
                switch self {
                case .source: return MoneyViewController.Model.Sign.source
                case .target: return MoneyViewController.Model.Sign.target
                }
            }
        }
        var identifier: Identifier!

        var chosenCurrency: String?
        var chosenMoney: Money? {
            return find(by: self.chosenCurrency)
        }
        var chosenIndex: Int? {
            return index(of: self.chosenCurrency)
        }
        var value: Double?
        var chosenValue: Double? {
            return self.value
        }
        
        
        private(set) var moneyList: NSFetchedResultsController<Money>?
        weak var observingDelegate: MoneyListViewControllerModelObservingProtocol?
        weak var modelDelegate: MoneyListViewControllerModelProtocol?
        
        init(moneyList: NSFetchedResultsController<Money>?, identifier: Identifier!) {
            super.init()
            _ = self.configuredByMoney(money: moneyList)
            self.identifier = identifier
        }
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension MoneyListViewController.Model: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let name = controller.fetchRequest.entityName else {
            return
        }
        
        switch name {
            case Money.mr_entityName():
            // do something?
            // we must update all controllers, correct?
            // and tell about it to something?
            self.observingDelegate?.didUpdateMoney(current: self.chosenMoney)
        default: break
        }
    }
}

//MARK: Find ( returns database money )
extension MoneyListViewController.Model {
    func find(by currency: String?) -> Money? {
        return self.moneyList?.fetchedObjects?.filter({
            guard let theCurrency = $0.currency, let sourceCurrency = currency else {
                return false
            }
            return theCurrency == sourceCurrency
        }).first
    }
    func index(of currency: String?) -> Int? {
        return self.moneyList?.fetchedObjects?.index(where: {
            guard let theCurrency = $0.currency, let sourceCurrency = currency else {
                return false
            }
            return theCurrency == sourceCurrency
        })
    }
    func numberOfObjects() -> Int {
        return self.moneyList?.fetchedObjects?.count ?? 0
    }
}

//MARK: Update
extension MoneyListViewController.Model {
    func updateCurrency(currency: String?) {
        // we should update currency and tell about it.
        self.chosenCurrency = currency
        observingDelegate?.didUpdateCurrency(currency: currency)
    }
    func updateValue(value: Double?) {
        self.value = value
        observingDelegate?.didUpdateValue(value: value ?? 0)
    }
}

// MARK: Model events
extension MoneyListViewController.Model {
    func selectCurrency() {
        self.modelDelegate?.didSelectCurrency(current: self.chosenCurrency)
    }
}

// MARK: Configuration
extension MoneyListViewController.Model {
    func configuredByMoney(money: NSFetchedResultsController<Money>?) -> Self {
        self.moneyList = money
        self.moneyList?.delegate = self
        return self
    }
}
