//
//  RSDConditionalStepNavigator.swift
//  Research
//

import Foundation


/// Extension of the `RSDOrderedStepNavigator` to implement a shared navigation.
public protocol RSDConditionalStepNavigator : RSDOrderedStepNavigator {
}

extension RSDConditionalStepNavigator {
    
    @available(*,deprecated, message: "Will be deleted in a future version.")
    public var trackingRules : [RSDTrackingRule] {
        return RSDFactory.shared.trackingRules
    }
    
    public func navigationRule(for step: RSDStep) -> RSDNavigationRule? {
        return step as? RSDNavigationRule
    }
    
    public func navigationSkipRule(for step: RSDStep) -> RSDNavigationSkipRule? {
        return step as? RSDNavigationSkipRule
    }
    
    public func navigationBackRule(for step: RSDStep) -> RSDNavigationBackRule? {
        return step as? RSDNavigationBackRule
    }
}
