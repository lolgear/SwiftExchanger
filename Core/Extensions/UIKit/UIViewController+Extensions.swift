//
//  UIViewController+Extensions.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 13.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import SwiftMessages

extension UIViewController {
    func showNotificationError(error: Error?) {
        guard let currentError = error else {
            return
        }
        let view = MessageView.viewFromNib(layout: .tabView)
        view.configureTheme(.error)
        view.button?.isHidden = true
        view.configureContent(title: "Error", body: currentError.localizedDescription, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        SwiftMessages.show(view: view)
        // show error :/
    }
    func hideAllNotifications() {
        SwiftMessages.hideAll()
    }
}
