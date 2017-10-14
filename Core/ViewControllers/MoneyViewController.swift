//
//  MoneyViewController.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 09.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit
class MoneyViewController: UIViewController {
    //MARK: Structures
    struct Model {
        var currency: String
        var value: Double
        var exchange: Double
        var sign: Sign
        enum Sign {
            case source
            case target
            var sign: String {
                switch self {
                case .source: return "-"
                case .target: return "+"
                }
            }
        }
    }
    
    //MARK: Properties
    var model: Model?
//    var currencyLabel: UILabel!
//    var valueLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    //MARK: Init
}

//MARK: Setup by structure
//USAGE: call when you want to update values.
extension MoneyViewController {
    func setup(by model: Model) {
        // setup by
        self.model = model
        self.updateUI()
    }
    func configured(by model: Model) -> Self {
        self.setup(by: model)
        return self
    }
}

//MARK: Update UI
extension MoneyViewController {
    //NOTE: Thread-safe ( main thread )
    func updateUI() {
        DispatchQueue.main.async {
            if let model = self.model {
                self.currencyLabel.text = model.currency
                // add money format
                self.valueLabel.text = "\(model.value)"
                self.exchangeLabel.text = "(\(model.sign)\(model.exchange))"
            }
        }
    }
}
