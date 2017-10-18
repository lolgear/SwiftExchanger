//
//  MoneyListViewController.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 09.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import DatabaseBeaver
import SnapKit

@objc protocol MoneyListViewControllerFlippingProtocol {
    func didChoose(money: Money?, at index: Int, for model: MoneyListViewController.Model?, in widget: String)
}

//Maybe model should not be so smart?
//And we should add MoneyModel also?
class MoneyListViewController: UIViewController {
    //MARK: Properties
    var model: Model!
    var pageViewController: UIPageViewController?
    var pageControl: UIPageControl?
    
    //MARK: View Lifecycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.addConstraints()
        self.updateUI()
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
    }
    
    //MARK: View Lifecycle extended.
    func setupUIElements() {
        
        self.pageViewController = {
            let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation:.horizontal , options: nil)
            controller.delegate = self
            controller.dataSource = self
            return controller
        }()
    }
    
    func addConstraints() {
        self.view.filled(by: self.pageViewController)
    }
}

//MARK: Update model?
extension MoneyListViewController {
    func setup(by model: Model) {
        self.model = model
        self.model.observingDelegate = self
        self.updateUI()
    }
    func configured(by model: Model) -> Self {
        self.setup(by: model)
        return self
    }
}

//MARK: Update UI
extension MoneyListViewController {
    func updateUI() {
        DispatchQueue.main.async {
            self.pageControl?.numberOfPages = self.model.numberOfObjects()
            // we need new model object.
            // else - we need to find correct VC
            
            if let viewController = self.currentViewController() {
                guard let money = self.model.find(by: viewController.model?.currency), let currency = money.currency else {
                    return
                }
                let model = MoneyViewController.Model(currency: currency, value: money.value, exchange: self.model.chosenValue ?? 0, sign: self.model.identifier.sign)
                viewController.setup(by: model)
            }
            else {
                // set for currency.
                guard let viewController = self.viewController(currency: self.model?.chosenCurrency) else {
                    return
                }
                self.pageViewController?.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
            }
        }
    }
}

//MARK: ViewControllers
extension MoneyListViewController {
    func currentViewController() -> MoneyViewController? {
        guard let viewController = self.pageViewController?.viewControllers?.first else {
            return nil
        }
        return viewController as? MoneyViewController
    }
    func index(ofViewController viewController: UIViewController?) -> Int? {
        guard let theViewController = viewController as? MoneyViewController else {
            return nil
        }
        return self.model.index(of: theViewController.model?.currency)
    }
    func viewController(currency: String?) -> UIViewController? {
        guard let found = self.model.find(by: currency) else {
            return nil
        }
        return viewController(money: found)
    }
    
    func viewController(money: Money?) -> UIViewController? {
        guard let theMoney = money, let currency = money?.currency else {
            return nil
        }
        let model = MoneyViewController.Model(currency: currency, value: theMoney.value, exchange: self.model.chosenValue ?? 0, sign: self.model.identifier.sign)
        return MoneyViewController().configured(by: model)
    }
    
    func viewController(index: Int?) -> UIViewController? {
        guard let theIndex = index else {
            return nil
        }
        
        guard true == self.model.moneyList?.fetchedObjects?.indices.contains(theIndex) else {
            return nil
        }
        
        return viewController(money: self.model.moneyList?.fetchedObjects?[theIndex])
    }
}

//MARK: UIPageViewControllerDataSource
extension MoneyListViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = self.index(ofViewController: viewController) else {
            return nil
        }
        
        guard let nextIndex = self.model.moneyList?.fetchedObjects?.safeNextIndex(for: currentIndex, cyclic: true) else {
            return nil
        }
        
        guard let result = self.viewController(index: nextIndex) else {
            return nil
        }
        return result
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = self.index(ofViewController: viewController) else {
            return nil
        }
        
        guard let nextIndex = self.model.moneyList?.fetchedObjects?.safeNextIndex(for: currentIndex, cyclic: true) else {
            return nil
        }
        
        guard let result = self.viewController(index: nextIndex) else {
            return nil
        }
        return result
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.model.numberOfObjects()
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        let index = self.model.chosenIndex
        let result = index ?? 0
        print("index: \(String(describing: index)), result: \(result)")
        return result
    }
}

//MARK: UIPageViewControllerDelegate
extension MoneyListViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard finished && completed else {
            return
        }
        
        guard let index = self.index(ofViewController: pageViewController.viewControllers?.first) else {
            return
        }
        
        let money = self.model.moneyList?.fetchedObjects?[index]
        self.model.chosenCurrency = money?.currency
        // trigger to update model and recalculate quote rate for chosen currency.
        self.model.selectCurrency()
    }
}

//MARK: MoneyListViewControllerModelObservingProtocol
extension MoneyListViewController: MoneyListViewControllerModelObservingProtocol {
    func didUpdateMoney(current: Money?) {
        guard let money = current, let currency = money.currency else {
            return
        }
        
        let model = MoneyViewController.Model(currency: currency, value: money.value, exchange: self.model.chosenValue ?? 0, sign: self.model.identifier.sign)
        self.currentViewController()?.setup(by: model)
    }
    
    func didUpdateCurrency(currency: String?) {
        // scroll to currency?
        // or just show it?
        self.updateUI()
    }
    
    func didUpdateValue(value: Double) {
        self.updateUI()
    }
}
