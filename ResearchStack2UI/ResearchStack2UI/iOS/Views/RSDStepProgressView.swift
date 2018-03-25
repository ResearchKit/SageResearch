//
//  RSDStepProgressView.swift
//  ResearchStack2UI
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
open class RSDStepProgressView: UIView, RSDViewColorStylable {
    
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
    
    /// Should the progress bar display with a light style of progress bar and label for use
    /// on a dark background, or with a dark style of progress bar for use on a light background?
    @IBInspectable
    open var usesLightStyle: Bool = false {
        didSet {
            updateColorStyle()
        }
    }
    
    /// Should the inner progress bar end be rounded on the right side?
    open var hasRoundedProgressEnd: Bool = UIView.rsd_progressViewRoundedEnds {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /// Should the label associated with the progress bar display all capital letters?
    open var labelIsUppercase: Bool = UIView.rsd_progressViewStepLabelUppercase {
        didSet {
            updateLabel()
        }
    }
    
    /// Should the label associated with the progress bar display the current step number
    /// as bolded?
    open var labelCurrentStepIsBold: Bool = UIView.rsd_progressViewCurrentStepBolded {
        didSet {
            updateLabel()
        }
    }
    
    private func updateColorStyle() {
        // Update colors
        progressView.backgroundColor = UIColor.rsd_progressBar
        if usesLightStyle {
            backgroundView.backgroundColor = UIColor.rsd_progressBarBackgroundLightStyle
            stepCountLabel?.textColor = UIColor.rsd_stepCountLabelLightStyle
        } else {
            backgroundView.backgroundColor = UIColor.rsd_progressBarBackground
            stepCountLabel?.textColor = UIColor.rsd_stepCountLabel
        }
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
    
    /// The text of the label that is displayed directly under the progress bar.
    open func attributedStringForLabel() -> NSAttributedString? {

        if currentStep > 0 && totalSteps > 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            let currentString = formatter.string(for: currentStep)!
            let totalString = formatter.string(for: totalSteps)!
            let marker = "<CURRENT_STEP>"
            
            let format = Localization.localizedString("CURRENT_STEP_%@_OF_TOTAL_STEPS_%@")
            let str = String.localizedStringWithFormat(format, marker, totalString)
            let mutableString = NSMutableString(string: str)
            let markerRange = mutableString.range(of: marker)
            mutableString.replaceCharacters(in: markerRange, with: currentString)
            let fullStr : String = labelIsUppercase ? (mutableString as String).uppercased() : mutableString as String
            let range = NSRange(location: markerRange.location, length: (currentString as NSString).length)
            let attributedString = NSMutableAttributedString(string: fullStr)
            if labelCurrentStepIsBold {
                attributedString.addAttribute(.font, value: UIFont.rsd_boldStepCountLabel, range: range)
            }
            
            return attributedString
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

        updateColorStyle()
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
        
        stepCountLabel?.attributedText = attributedStringForLabel()
    }
}
