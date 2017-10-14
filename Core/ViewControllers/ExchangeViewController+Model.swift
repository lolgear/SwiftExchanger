//
//  ExchangeViewController+Model.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 11.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import CoreData
import DatabaseBeaver

protocol ExchangeViewControllerModelObservingProtocol {
    func didUpdateQuotes(_ current: Quotable?)
}

extension ExchangeViewController {
    class Model: NSObject {
        //MARK: Properties
        private(set) var sourceCode: String?
        private(set) var targetCode: String?
        var quotes: NSFetchedResultsController<Quote>?
        
        var sourceModel: MoneyListViewController.Model?
        var targetModel: MoneyListViewController.Model?
        var observingDelegate: ExchangeViewControllerModelObservingProtocol?
        override init() {}
    }
}

// MARK: Observing Quotes
extension ExchangeViewController.Model: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // we update quotes.
        // also, we update money.
        if let entityName = controller.fetchRequest.entityName {
            switch (entityName) {
            case Quote.mr_entityName():
                let quote = self.currentQuote
                observingDelegate?.didUpdateQuotes(quote)
                self.updateTargetValue(withQuote: quote)
            default: return // nothing in this case.
            }
        }
    }
}

// MARK: Find
extension ExchangeViewController.Model {
    func findQuote(_ source: String, _ target: String, in context: NSManagedObjectContext) -> Quotable? {
        return Quote.virtualFind(source: source, target: target, context: context)
    }
}

// MARK: Configuration
extension ExchangeViewController.Model {
    func configuredByQuotes(_ quotes: NSFetchedResultsController<Quote>?) -> Self {
        self.quotes = quotes
        self.quotes?.delegate = self
        return self
    }
    
    func configuredByCurrencies(_ sourceCode: String, _ targetCode: String) -> Self {
        self.sourceCode = sourceCode
        self.targetCode = targetCode
        if let model = self.sourceModel {
            model.updateCurency(currency: self.sourceCode)
        }
        if let model = self.targetModel {
            model.updateCurency(currency: self.targetCode)
        }
        return self
    }
    
    func configuredByMoney(_ sourceMoney: NSFetchedResultsController<Money>?, _ targetMoney: NSFetchedResultsController<Money>?) -> Self {
        if let model = self.sourceModel {
            _ = model.configuredByMoney(money: sourceMoney)
        }
        else {
            self.sourceModel = MoneyListViewController.Model(moneyList: sourceMoney)
        }
        
        if let model = self.targetModel {
            _ = model.configuredByMoney(money: targetMoney)
        }
        else {
            self.targetModel = MoneyListViewController.Model(moneyList: targetMoney)
        }
        return self
    }
}

//MARK: Update
extension ExchangeViewController.Model {
    func updateSourceValue(value: Double) {
        // update underlying models also.
        if let model = self.sourceModel {
            model.updateValue(value: value)
        }
        updateTargetValue(withSource: value)
    }
    
    func updateTargetValue(with sourceValue: Double?, quote: Quotable?) {
        if let model = self.targetModel,
        let theSourceValue = sourceValue,
        let theQuote = quote {
            let value = theSourceValue * theQuote.quote
            model.updateValue(value: value)
        }
    }
    
    func updateTargetValue(withSource source: Double?) {
        self.updateTargetValue(with: source, quote: self.currentQuote)
    }
    
    func updateTargetValue(withQuote quote: Quotable?) {
        self.updateTargetValue(with: self.currentSourceValue, quote: quote)
    }
}

//MARK: Exchange
extension ExchangeViewController.Model {
    var currentQuote: Quotable? {
        guard let sourceCode = self.sourceCode, let targetCode = self.targetCode, let context = self.quotes?.managedObjectContext else {
            return nil
        }
        return self.findQuote(sourceCode, targetCode, in: context)
    }
    
    var currentSourceCode: String? {
        return self.sourceModel?.chosenCurrency
    }
    
    var currentSourceValue: Double? {
        return self.sourceModel?.chosenValue
    }
    
    var currentTargetCode: String? {
        return self.targetModel?.chosenCurrency
    }
    
    var conversionError: Error? {
        return ConversionModel(sourceCode: self.currentSourceCode, targetCode: self.currentTargetCode).error
    }
    
    func exchange(completion: ((Bool, Error?) -> Void)?) {
        let exchange = ExchangeModel(sourceCode: self.currentSourceCode, targetCode: self.currentTargetCode, sourceValue: self.currentSourceValue, quoteValue: self.currentQuote?.quote)
        DatabaseService.service()?.save(block: { context in
            guard let theContext = context else {
                return
            }
            do {
                try exchange.save(context: theContext)
            }
            catch let error {
                completion?(false, error)
            }
        }, completion: { result, error in
            guard let theError = error else {
                return
            }
            completion?(result, theError)
        })
    }
}
