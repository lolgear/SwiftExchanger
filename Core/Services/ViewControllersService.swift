//
//  ViewControllersService.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit
@objc protocol ViewControllersServiceNavigationActionProtocol {
    func shouldShow(controller: UIViewController?, for action:ViewControllersService.NavigationAction)
}
class ViewControllersService: BaseService {
    class NavigationAction: NSObject {
        weak var delegate: ViewControllersServiceNavigationActionProtocol?
        func configured(by delegate: ViewControllersServiceNavigationActionProtocol?) -> Self {
            self.delegate = delegate
            return self
        }
        @objc func action(button: UIBarButtonItem?) {
            // add if needed.
            // we just want to
        }
        func title() -> String? {
            return ""
        }
        func barButton() -> UIBarButtonItem {
            return UIBarButtonItem(title: self.title(), style: .plain, target: self, action: #selector(NavigationAction.action) )
        }
        class ResetCash: NavigationAction {
            override func action(button: UIBarButtonItem?) {
                guard let database = DatabaseService.service() else {
                    return
                }
                database.resetCash()
            }
            override func title() -> String? {
                return "Reset Cash"
            }
        }
        class ShowTransactions: NavigationAction {
            override func action(button: UIBarButtonItem?) {
                self.delegate?.shouldShow(controller: TransactionsViewController.defaultController(), for: self)
            }
            override func title() -> String? {
                return "Transactions"
            }
        }
        // bind to itself
        enum NavigationActionType {
            case resetCash
            case showTransactions
            func action() -> NavigationAction {
                switch self {
                case .resetCash: return ResetCash()
                case .showTransactions: return ShowTransactions()
                }
            }
        }
    }
    var rootViewController: UIViewController?
    var leftActions: [NavigationAction]?
    var rightActions: [NavigationAction]?
}

//MARK: Controller preparation
extension ViewControllersService {
    func blessedController() -> UIViewController? {
        guard let viewController = self.rootViewController else {
            return nil
        }
        let controller = UINavigationController(rootViewController: viewController)
        controller.navigationItem.leftBarButtonItems = self.leftActions?.map {$0.barButton()}
        controller.navigationItem.rightBarButtonItems = self.rightActions?.map {$0.barButton()}
        controller.viewControllers.first?.navigationItem.leftBarButtonItems = controller.navigationItem.leftBarButtonItems
        controller.viewControllers.first?.navigationItem.rightBarButtonItems = controller.navigationItem.rightBarButtonItems
        return controller
    }
}

//MARK: ServicesInfoProtocol
extension ViewControllersService {
    override var health: Bool {
        return rootViewController != nil
    }
}

//MARK: ServicesSetupProtocol
extension ViewControllersService {
    override func setup() {
        // setup all necessary items and after that we are ready for rootViewController
        self.leftActions = [NavigationAction.NavigationActionType.resetCash.action()]
        self.rightActions = [NavigationAction.NavigationActionType.showTransactions.action().configured(by: self)]
    }
}

//MARK: ActionHandling
extension ViewControllersService: ViewControllersServiceNavigationActionProtocol {
    func shouldShow(controller: UIViewController?, for action: ViewControllersService.NavigationAction) {
        guard let theController = controller else {
            return
        }
        self.rootViewController?.navigationController?.pushViewController(theController, animated: true)
    }
}
