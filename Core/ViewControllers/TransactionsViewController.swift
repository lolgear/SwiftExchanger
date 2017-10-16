//
//  TransactionsViewController.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import DatabaseBeaver
class TransactionsViewController: UITableViewController {    
    var model: Model!
}

// MARK: View Lifecycle
extension TransactionsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupController()
        self.setupTableView()
    }
}

// MARK: Setup
extension TransactionsViewController {
    func setupController() {
        // add localization later.
        self.title = "Transactions"
    }
    func setupTableView() {        
        self.tableView.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.cellReuseIdentifier())
        self.tableView.allowsSelection = false
    }
}

// MARK: Configuration
extension TransactionsViewController {
    func configured(by model: Model) -> Self {
        self.model = model
        self.model.observingDelegate = self
        return self
    }
}

// MARK: UITableViewDataSource
extension TransactionsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.model.numberOfSections()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.numberOfObjects(in: section)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.cellReuseIdentifier(), for: indexPath) as? TransactionTableViewCell else {
            return UITableViewCell()
        }
        guard let object = self.model.objectAtIndexPath(indexPath: indexPath) else {
            return UITableViewCell()
        }
        
        return cell.configured(byExchangeModel: object)
    }
}

// MARK: DefaultController
extension TransactionsViewController {
    class func defaultController() -> UIViewController {
        return TransactionsViewController().configured(by: TransactionsViewController.Model().configured(by: DatabaseService.service()?.fetchExchanges(delegate: nil)))
    }
}

// MARK: Model Observing
extension TransactionsViewController: TransactionsViewControllerModelObservingProtocol {
    func didUpdateModel() {
        self.tableView.reloadData()
    }
}
