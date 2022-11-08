//
//  NSLayoutConstraint+Layout.swift
//  ResearchUI
//
//  Created by Josh Bruhin on 5/26/17.

import Foundation
import UIKit

extension NSLayoutConstraint {
    
    /// Change the multiplier on a constraint by creating a new constraint with all the same
    /// properties and the new multiplier
    /// - parameter multiplier: The new multipler value.
    /// - returns: A new constraint with the new multiplier value.
    public func rsd_setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
