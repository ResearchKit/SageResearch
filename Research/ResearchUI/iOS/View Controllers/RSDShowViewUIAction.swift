//
//  RSDShowViewUIAction.swift
//  ResearchUI (iOS)
//

import Foundation
import Research
import UIKit

/// For the case where the learn more action is designed specifically for showing a view controller, this
/// allows for vending a custom learn more action without requiring a custom step view.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDShowViewUIAction : RSDUIAction {
    
    /// The view controller to show.
    func instantiateViewController(for stepViewModel: RSDStepViewPathComponent) -> UIViewController
}
