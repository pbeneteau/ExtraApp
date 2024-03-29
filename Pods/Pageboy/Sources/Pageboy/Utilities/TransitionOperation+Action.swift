//
//  TransitionOperation+Action.swift
//  Pageboy
//
//  Created by Merrick Sapsford on 30/05/2017.
//  Copyright © 2017 Merrick Sapsford. All rights reserved.
//

import Foundation

internal extension TransitionOperation {
    
    /// Action that occurs in an operation.
    struct Action {
        
        /// The page start index.
        let startIndex: Int
        /// The page end index.
        let endIndex: Int
        /// The direction of travel.
        let direction: PageboyViewController.NavigationDirection
        /// The orientation of the page view controller.
        let orientation: UIPageViewControllerNavigationOrientation
        
    }
}

internal extension TransitionOperation.Action {
    
    /// Animation sub-type for the action.
    var transitionSubType: String {
        switch orientation {
            
        case .horizontal:
            switch direction {
                
            case .reverse:
                return kCATransitionFromLeft
            default:
                return kCATransitionFromRight
            }
            
        case .vertical:
            switch direction {
                
            case .reverse:
                return kCATransitionFromTop
            default:
                return kCATransitionFromBottom
            }
        }
    }
}
