//
//  DebugStepViewController.swift
//  ResearchUI
//

import UIKit
import Research

/// `DebugStepViewController` is an internal class that is used to display a view controller for a step without any UI.
/// This allows the developer to use a placeholder view controller when developing a new task.
@available(iOS 13.0, *)
class DebugStepViewController: RSDStepViewController {
    
    /// A label for displaying the step identifier.
    @IBOutlet var identifierLabel: UILabel!
    
    /// A label for displaying the step description.
    @IBOutlet var titleLabel: UILabel!
    
    /// Default initializer used to display "DebugStepViewController.xib" for the given step.
    public override init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: "DebugStepViewController", bundle: Bundle.module)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
    }
    
    /// Required initializer. Unused.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Override `viewWillAppear()` to set the identifier label and title label.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the view
        self.identifierLabel.text = self.step.identifier
        self.titleLabel.text = String(describing: self.step!)
    }
    
    /// Override to always allow forward navigation.
    override var isForwardEnabled: Bool {
        return true
    }
}
