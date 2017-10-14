//
//  KeyboardService.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 13.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
class KeyboardService: BaseService {
    
}

extension KeyboardService {
    override var health: Bool {
        return IQKeyboardManager.sharedManager().enable
    }
}

extension KeyboardService {
    override func setup() {
        IQKeyboardManager.sharedManager().enable = true
    }
}
