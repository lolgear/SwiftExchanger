//
//  TransactionTableViewCell.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit
import DatabaseBeaver

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var fromCurrency: UILabel!
    @IBOutlet weak var toCurrency: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var sourceValue: UILabel!
    @IBOutlet weak var targetValue: UILabel!
    @IBOutlet weak var quote: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configured(byExchangeModel model: Exchange) -> Self {
        self.fromCurrency.text = model.sourceCode
        self.toCurrency.text = model.targetCode
        self.timestamp.text = CustomDateFormatter.dateFromString(value: model.timestamp)
        self.sourceValue.text = MoneyFormatter.moneyFromDouble(value: model.sourceValue , currency: model.sourceCode)
        self.targetValue.text = MoneyFormatter.moneyFromDouble(value: model.targetValue , currency: model.targetCode)
        self.quote.text = MoneyFormatter.numberWithFractionFromDouble(value: model.sourceValue == 0 ? 0 : model.targetValue / model.sourceValue)
        return self
    }
}
