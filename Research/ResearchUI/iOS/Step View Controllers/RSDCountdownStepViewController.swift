//
//  RSDCountdownStepViewController.swift
//  ResearchUI
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit
import Research

open class RSDFullscreenImageStepViewController: RSDStepViewController {
    
    /// Override to return the primary background color for all placements.
    open override func defaultBackgroundColorTile(for placement: RSDColorPlacement) -> RSDColorTile {
        return self.designSystem.colorRules.backgroundPrimary
    }
    
    open override func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        // Header and footer may have an image behind them so they need to set up their components for
        // the background color, but then *not* use that color as their background.
        if placement == .header {
            self.navigationHeader?.backgroundColor = UIColor.clear
        }
        else if placement == .footer {
            self.navigationFooter?.backgroundColor = UIColor.clear
        }
    }
    
}

/// `RSDCountdownStepViewController` is a simple countdown timer for displaying a short duration (5-4-3-2-1) countdown.
///
/// This view controller includes a default nib implementation that is included in this framework. It includes a `countdownLabel`
/// that can be used to show a numeric countdown (5-4-3-2-1) and a `pauseButton` that can be used to pause the countdown timer.
/// 
/// - seealso: `RSDTaskViewController.vendDefaultViewController(for:)`
///
open class RSDCountdownStepViewController: RSDFullscreenImageStepViewController {
    
    /// A label that is updated to show a countdown (5-4-3-2-1).
    @IBOutlet open var countdownLabel: UILabel?
    
    /// A button that can be used to pause/resume the countdown timer.
    @IBOutlet open var pauseButton: UIButton?
    
    /// This class overrides `didSet` to update the `countdownLabel` to the new value.
    override open var countdown: Int {
        didSet {
            countdownLabel?.text = numberFormatter.string(from: NSNumber(value: countdown))
        }
    }
    
    /// The number formatter to use to show the countdown number.
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.allowsFloats = false
        numberFormatter.generatesDecimalNumbers = true
        return numberFormatter
    }()
    
    /// Toggle the state of the `pauseButton` to pause/resume the countdown.
    @IBAction open func pauseTimer() {
        if self.clock?.isPaused ?? false {
            self.pauseButton?.setTitle(Localization.buttonPause(), for: .normal)
            self.resume()
        }
        else {
            self.pauseButton?.setTitle(Localization.buttonResume(), for: .normal)
            self.pause()
        }
    }
    
    /// Override setting the color style to set the color of the label.
    open override func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        if placement == .body {
            countdownLabel?.textColor = countdownLabelColor(on: background)
            countdownLabel?.font = self.designSystem.fontRules.font(for: .largeNumber, compatibleWith: traitCollection)
            self.pauseButton?.setTitle(Localization.buttonPause(), for: .normal)
            (self.pauseButton as? RSDViewDesignable)?.setDesignSystem(self.designSystem, with: background)
        }
    }
    
    /// Returns the color to use for the countdown label
    open func countdownLabelColor(on background: RSDColorTile) -> UIColor {
        return self.designSystem.colorRules.textColor(on: background, for: .largeNumber)
    }
    
    // MARK: Initialization
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: RSDCountdownStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    open class var bundle: Bundle {
        return Bundle.module
    }
    
    /// Default initializer. This initializer will initialize using the `nibName` and `bundle` defined on this class.
    /// - parameter step: The step to set for this view controller.
    public override init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: type(of: self).nibName, bundle: type(of: self).bundle)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
    }
    
    /// Initialize the class using the given nib and bundle.
    /// - note: If this initializer is used with a `nil` nib, then it must assign the expected outlets.
    /// - parameters:
    ///     - nibNameOrNil: The name of the nib or `nil`.
    ///     - nibBundleOrNil: The name of the bundle or `nil`.
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Required initializer. This is the initializer used by a `UIStoryboard`.
    /// - parameter aDecoder: The decoder used to initialize this view controller.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
