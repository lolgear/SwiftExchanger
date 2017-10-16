//
//  ExchangeViewController.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 29.09.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

// user did a swipe.
// we should update currencies and rates.
// add model?
import Foundation
import UIKit
import CoreData
import DatabaseBeaver
import SnapKit
import SwiftMessages
class ExchangeViewController: UIViewController {    
    //MARK: Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sourceView: UIView!
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    private(set) var sourceViewController: MoneyListViewController?
    private(set) var targetViewController: MoneyListViewController?
    
    var model: Model?
    
    // View Lifecycle
    public override func viewDidLoad() {
        self.setupUIElements()
        self.addConstraints()
        self.updateUI()
    }
    
    // Custom View Lifecycle
    func setupUIElements() {
        guard let sourceModel = self.model?.sourceModel, let targetModel = self.model?.targetModel else {
            // error?
            return
        }
        
        // refresh control
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self,
                                     action: #selector(didPullToRefresh(sender:)),
                                     for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
        
        // source
        self.sourceViewController = {
            let controller = MoneyListViewController().configured(by: sourceModel)
            return controller
        }()
        
        self.targetViewController = {
            let controller = MoneyListViewController().configured(by: targetModel)
            return controller
        }()
        
        // textField
        // input text field default value is zero.
        setTextFieldToDefaultValueIfNeeded(textField: self.inputTextField)
        self.didUpdateInput(input: self.inputTextField.text)
        // and also we have delegate for it.
        self.inputTextField.delegate = self
    }
    
    func addConstraints() {
        self.sourceView.filled(by: self.sourceViewController)
        self.targetView.filled(by: self.targetViewController)
    }
}

// MARK: SetupByModel
extension ExchangeViewController {
    func configured(by model: Model) -> Self {
        self.setup(by: model)
        return self
    }
    
    func setup(by model: Model) {
        // added needed items here.
        self.model = model
        self.updateUI()
    }
}

// MARK: UpdateUI
extension ExchangeViewController {
    func updateUI() {
        DispatchQueue.main.async {
            self.sourceViewController?.updateUI()
            self.targetViewController?.updateUI()
            // update current label with targetValue.
            // and all?
        }
    }
}

// MARK: Refresh
extension ExchangeViewController {
    @objc func didPullToRefresh(sender: UIRefreshControl) {
        DataProviderService.service()?.dataProvider.updateQuotes(completion: { result, error in
            DispatchQueue.main.async {
                sender.endRefreshing()
            }
        })
    }
}

// MARK: Notifications
extension ExchangeViewController {
    func showError(error: Error?) {
        DispatchQueue.main.async {
            self.showNotificationError(error: error)
        }
    }
}

//MARK: UITextFieldDelegate
extension ExchangeViewController: UITextFieldDelegate {
    func setTextFieldToDefaultValueIfNeeded(textField: UITextField!) {
        if (textField.text ?? "").isEmpty {
            textField.text = "0"
            didUpdateInput(input: textField.text)
        }
    }
    func didUpdateInput(input: String?) {
        let input = Double(input ?? "") ?? 0
        self.model?.updateSourceValue(value: input)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTextFieldToDefaultValueIfNeeded(textField: textField)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let resultString = nsString?.replacingCharacters(in: range, with: string)
        didUpdateInput(input: resultString)
        
        return true
    }
}

//MARK: Actions
extension ExchangeViewController {
    func applyExchange() {
        // try to exchange somehow?
        if let error = self.model?.conversionError {
            showError(error: error)
            return
        }
        
        self.model?.exchange(completion: {
            [unowned self]
            result, error in
            if let thError = error {
                self.showError(error: thError)
            }
        })
    }
    @IBAction func exchangeButtonDidPressed(_ sender: UIButton) {
        applyExchange()
    }
}
