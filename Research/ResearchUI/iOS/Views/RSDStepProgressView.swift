//
//  RSDStepProgressView.swift
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

/// `RSDStepProgressView` is a UI element that displays a progress bar drawn horizontally
/// from left to right.
///
/// This view includes an optional pointer to `stepCountLabel` which is *not* a subview of
/// this view but can be used to display current step and number of steps.
///
/// The view controller must set `currentStep` and `totalSteps` to cause progress to be
/// displayed.
///
@IBDesignable
open class RSDStepProgressView: UIView, RSDViewDesignable {
    
    /// A pointer to the label that should be updated with the current progress.
    @IBOutlet public weak var stepCountLabel: UILabel?

    /// The current step in the current flow.
    @IBInspectable
    public var currentStep: Int = 0 {
        didSet {
            progressChanged()
        }
    }
    
    /// The total number of steps in the current flow.
    @IBInspectable
    open var totalSteps: Int = 0 {
        didSet {
            progressChanged()
        }
    }
    
    /// Should the progress bar display with rounded ends?
    @IBInspectable
    open var hasRoundedEnds: Bool = false {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /// Should the inner progress bar end be rounded on the right side?
    open var hasRoundedProgressEnd: Bool = false {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    // TODO: syoung 03/19/2019 Remove these properties once the modules that use them have been updated.
    @available(*, unavailable)
    open var usesLightStyle: Bool = false
    
    @available(*, unavailable)
    open var labelIsUppercase: Bool = false
    
    @available(*, unavailable)
    open var labelCurrentStepIsBold: Bool = false
    
    /// The background color mapping that this view should use as its key. Typically, for all but the
    /// top-level views, this will be the background of the superview.
    open private(set) var backgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    open private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.backgroundColorTile = background
        self.designSystem = designSystem
        updateColorsAndFonts()
    }

    private func updateColorsAndFonts() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let colorTile: RSDColorTile = self.backgroundTile() ?? designSystem.colorRules.backgroundPrimary
        
        // Update colors and fonts
        let rules = designSystem.colorRules.progressBar(on: colorTile)
        progressView.backgroundColor = rules.filled
        backgroundView.backgroundColor = rules.unfilled
        stepCountLabel?.textColor = designSystem.colorRules.textColor(on: colorTile, for: .microHeader)
        stepCountLabel?.font = designSystem.fontRules.font(for: .microHeader, compatibleWith: traitCollection)
    }

    /// The height of the actual progress bar.
    @IBInspectable
    open var progressLineHeight: CGFloat = 10.0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /// The progress (0 - 1.0) to display.
    public var progress: CGFloat {
        if totalSteps > 0 {
            return CGFloat(currentStep) / CGFloat(totalSteps)
        } else {
            return 0.0
        }
    }
    
    /// Returns `true` if the total steps is greather than `0`.
    public var hasProgress: Bool {
        return self.totalSteps > 0
    }
    
    @available(*, unavailable)
    open func attributedStringForLabel() -> NSAttributedString? {
        return nil
    }
    
    /// The text of the label that is displayed directly under the progress bar.
    open func stringForLabel() -> String? {
        if currentStep > 0 && totalSteps > 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            let currentString = formatter.string(for: currentStep)!
            let totalString = formatter.string(for: totalSteps)!
            let format = Localization.localizedString("CURRENT_STEP_%@_OF_TOTAL_STEPS_%@")
            return String.localizedStringWithFormat(format, currentString, totalString)
        }
        else {
            return nil
        }
    }
    
    // MARK: View Life-cycle
    
    private var progressView = UIView()
    private var backgroundView = UIView()
    
    public init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(progressView)
        backgroundView.clipsToBounds = true
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        updateColorsAndFonts()
        setNeedsUpdateConstraints()
    }
    
    private var _interactiveContraints: [NSLayoutConstraint] = []
    
    open override func updateConstraints() {
        
        let radius = progressLineHeight / 2.0
        // Round the ends
        if hasRoundedEnds {
            backgroundView.layer.cornerRadius = radius
        } else {
            backgroundView.layer.cornerRadius = 0.0
        }
        
        NSLayoutConstraint.deactivate(_interactiveContraints)
        _interactiveContraints.removeAll()
        
        _interactiveContraints.append(contentsOf:
            backgroundView.rsd_alignToSuperview([.leading, .trailing, .top, .bottom], padding: 0.0))
        _interactiveContraints.append(contentsOf:
            backgroundView.rsd_makeHeight(.equal, progressLineHeight))
        
        if hasRoundedProgressEnd {
            progressView.layer.cornerRadius = radius
            _interactiveContraints.append(contentsOf:
                progressView.rsd_alignToSuperview([.leading], padding: -radius))
        } else {
            progressView.layer.cornerRadius = 0.0
            _interactiveContraints.append(contentsOf:
                progressView.rsd_alignToSuperview([.leading], padding: 0.0))
        }
        _interactiveContraints.append(contentsOf:
            progressView.rsd_alignToSuperview([.top, .bottom], padding: 0.0))
        _interactiveContraints.append(contentsOf:
            progressView.rsd_makeWidthEqualToSuperview(multiplier: progress))
        
        super.updateConstraints()
    }
    
    func progressChanged() {
        if currentStep > 0 && totalSteps > 0 {
            
            if let widthConstraint = progressView.rsd_constraint(for: .width, relation: .equal) {
                _ = widthConstraint.rsd_setMultiplier(multiplier: progress)
                progressView.setNeedsLayout()
            }
            
            updateLabel()
            setNeedsLayout()
        }
    }
    
    /// Sets the text of the progress view label.
    /// Default = attributedStringForLabel()
    open func updateLabel() {
        stepCountLabel?.text = stringForLabel()
    }
}
