//
//  UITableViewCell.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit
extension UITableViewCell {
    class func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    class func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}

