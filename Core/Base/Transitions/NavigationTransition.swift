//
//  NavigationTransition.swift
//  SwiftExchanger
//
//  Created by Dmitry Lobanov on 12.06.2018.
//  Copyright © 2018 Lobanov Dmitry. All rights reserved.
//

import UIKit

class NavigationTransition: NSObject {
    let duration = 1.0
    let function = kCAMediaTimingFunctionEaseInEaseOut
}

class NavigationTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let fromController = transitionDuration(using: .from), let toController = transitionDuration(using: .to) else { return }
        
        
    }
}
