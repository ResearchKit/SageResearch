//
//  RSDResultSummaryStepViewController.swift
//  ResearchUI (iOS)
//

import UIKit
import Research

@available(*,deprecated, message: "Will be deleted in a future version.")
@available(iOS 13.0, *)
open class RSDResultSummaryStepViewController: RSDInstructionStepViewController {

    @IBOutlet public var resultTitleLabel: UILabel?
    @IBOutlet public var resultLabel: UILabel?
    @IBOutlet public var unitLabel: UILabel?
    
    open override var stepViewModel: RSDStepViewPathComponent! {
        get {
            return super.stepViewModel
        }
        set {
            super.stepViewModel = (newValue is RSDResultSummaryStepViewModel) ? newValue :
                self.instantiateStepViewModel(for: newValue.step, with: newValue.parent)
        }
    }
    
    /// Override the default behavior to instantiate a result summary step view model.
    override open func instantiateStepViewModel(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepViewPathComponent {
        return RSDResultSummaryStepViewModel(step: step, parent: parent)
    }
    
    /// Override to set the unit and result text.
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.resultTitleLabel?.text = self.resultTitle
        self.resultLabel?.text = self.resultText
        self.unitLabel?.text = self.unitText
    }
    
    /// Override to post accessibility announcement.
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        postAccessibilityAnnouncement()
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.resultTitleLabel?.font = self.designSystem.fontRules.baseFont(for: .largeHeader)
        self.resultLabel?.font = self.designSystem.fontRules.baseFont(for: .largeNumber)
        self.unitLabel?.font = self.designSystem.fontRules.baseFont(for: .largeHeader)
    }
    
    open override func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        
        self.resultTitleLabel?.textColor = self.designSystem.colorRules.textColor(on: background, for: .largeHeader)
        self.resultLabel?.textColor = self.designSystem.colorRules.textColor(on: background, for: .largeNumber)
        self.unitLabel?.textColor = self.designSystem.colorRules.textColor(on: background, for: .largeHeader)
    }
    
    open override func defaultBackgroundColorTile(for placement: RSDColorPlacement) -> RSDColorTile {
        if placement == .header {
            return self.designSystem.colorRules.palette.successGreen.normal
        }
        else {
            return self.designSystem.colorRules.backgroundLight
        }
    }
    
    /// The data source for view controller.
    open var resultData: RSDResultSummaryStepViewModel? {
        return self.stepViewModel as? RSDResultSummaryStepViewModel
    }
    
    /// The title to display above the result.
    open var resultTitle: String? {
        return self.resultData?.resultTitle
    }
    
    /// The result text to display.
    open var resultText: String? {
        return self.resultData?.resultText
    }
    
    /// The unit text to display.
    open var unitText: String? {
        return self.resultData?.unitText
    }

    func postAccessibilityAnnouncement() {
        var announcement: String = ""
        if let title = self.resultTitle {
            announcement.append(title)
        }
        if let result = self.resultText {
            announcement.append(" ")
            announcement.append(result)
        }
        if let unit = self.unitText {
            announcement.append(" ")
            announcement.append(unit)
        }
        let message = announcement.trimmingCharacters(in: .whitespaces)
        
        if message.count > 0 {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    // MARK: Initialization
    
    /// Static method to determine if this view controller class supports the provided step.
    ///
    /// This view controller is supported for steps that conform to the `RSDResultSummaryStep` protocol
    /// that have a `resultIdentifier`.
    open override class func doesSupport(_ step: RSDStep) -> Bool {
        
        // Must be a result step
        guard let resultStep = step as? RSDResultSummaryStep,
            resultStep.resultIdentifier != nil
            else {
                return false
        }
        
        // If there is an image then it must be for placement of icon above the title.
        if let placement = (step as? RSDDesignableUIStep)?.imageTheme?.placementType,
            placement != .iconBefore {
            return false
        }
        
        return true
    }
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open override class var nibName: String {
        return String(describing: RSDResultSummaryStepViewController.self)
    }
}
