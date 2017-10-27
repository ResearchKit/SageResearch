//
//  RSDStepProgressView.swift
//  ResearchSuiteUI
//
//  Created by Josh Bruhin on 5/25/17.
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

/**
 A UIView subclass that displays a progress bar going from left to right and a label
 that is positioned under the progress bar to display current step and number of steps.
 Views should set currentStep and totalSteps to cause progress to be displayed.
 */
@IBDesignable
open class RSDStepProgressView: UIView {

    /**
     The current step in the current flow.
     */
    @IBInspectable
    public var currentStep: Int = 0 {
        didSet {
            progressChanged()
        }
    }
    
    /**
     The total number of steps in the current flow.
     */
    @IBInspectable
    open var totalSteps: Int = 0 {
        didSet {
            progressChanged()
        }
    }
    
    /**
     Should the progress bar display with rounded ends?
     */
    @IBInspectable
    open var hasRoundedEnds: Bool = false {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     Should the progress bar display with a light style of progress bar and label for use on a dark background, or with a dark style of progress bar for use on a light background?
     */
    @IBInspectable
    open var usesLightStyle: Bool = false {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     Should the step label be hidden?
     */
    @IBInspectable
    open var isStepLabelHidden: Bool = false {
        didSet {
            stepCountLabel.isHidden = isStepLabelHidden
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     The height of the actual progress bar
     */
    @IBInspectable
    open var progressLineHeight: CGFloat = 10.0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    public var progress: CGFloat {
        if totalSteps > 0 {
            return CGFloat(currentStep) / CGFloat(totalSteps)
        } else {
            return 0.0
        }
    }
    
    // MARK: View elements
    
    public var stepCountLabel = UILabel()
    
    private var progressView = UIView()
    private var backgroundView = UIView()
    
    /**
     The text of the label that is displayed directly under the progress bar
     */
    open func stringForLabel() -> String? {

        if currentStep > 0 && totalSteps > 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            let currentString = formatter.string(for: currentStep)
            let totalString = formatter.string(for: totalSteps)
            let format = Localization.localizedString("CURRENT_STEP_%@_OF_TOTAL_STEPS_%@")
            return String.localizedStringWithFormat(format, currentString!, totalString!)
            
//            let attributedString = NSMutableAttributedString(string: "Step 3 of 4")
//            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "OpenSans-Bold", size: 14.0)!, range: NSRange(location: 5, length: 1))
        }
        else {
            return nil
        }
    }
    
    // MARK: Initializers
    
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
        
        self.addSubview(stepCountLabel)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        stepCountLabel.translatesAutoresizingMaskIntoConstraints = false

        stepCountLabel.font = UIFont.headerViewStepCountLabel
        stepCountLabel.numberOfLines = 1
        stepCountLabel.textAlignment = .center
        stepCountLabel.text = stringForLabel()
        stepCountLabel.isHidden = isStepLabelHidden
        
        setNeedsUpdateConstraints()
    }
    
    private var _interactiveContraints: [NSLayoutConstraint] = []
    
    open override func updateConstraints() {
        
        // Update colors
        progressView.backgroundColor = UIColor.progressBar
        if usesLightStyle {
            backgroundView.backgroundColor = UIColor.progressBarBackgroundLight
            stepCountLabel.textColor = UIColor.stepCountLabelLight
        } else {
            backgroundView.backgroundColor = UIColor.progressBarBackgroundDark
            stepCountLabel.textColor = UIColor.stepCountLabelDark
        }
        
        // Round the ends
        if hasRoundedEnds {
            backgroundView.layer.cornerRadius = progressLineHeight / 2.0
        } else {
            backgroundView.layer.cornerRadius = 0.0
        }
        
        NSLayoutConstraint.deactivate(_interactiveContraints)
        _interactiveContraints.removeAll()
        
        let progressHeight = (currentStep > 0 && totalSteps > 0) ? progressLineHeight : 0.0
        _interactiveContraints.append(contentsOf:
            backgroundView.alignToSuperview([.leading, .trailing, .top], padding: 0.0))
        _interactiveContraints.append(contentsOf:
            backgroundView.makeHeight(.equal, progressHeight))
        
        _interactiveContraints.append(contentsOf:
            progressView.alignToSuperview([.leading, .top, .bottom], padding: 0.0))
        _interactiveContraints.append(contentsOf:
            progressView.makeWidthEqualToSuperview(multiplier: progress))
        
        if stepCountLabel.superview == self, !isStepLabelHidden {
            _interactiveContraints.append(contentsOf:
                stepCountLabel.alignToSuperview([.bottomMargin], padding: 0.0))
            _interactiveContraints.append(contentsOf:
                stepCountLabel.alignCenterHorizontal(padding: 0))
            _interactiveContraints.append(contentsOf:
                stepCountLabel.alignBelow(view: progressView, padding: 5.0))
            _interactiveContraints.append(contentsOf:
                stepCountLabel.makeHeight(.greaterThanOrEqual, 0.0))
        } else {
            _interactiveContraints.append(contentsOf:
                backgroundView.alignToSuperview([.bottom], padding: 5.0))
        }
        
        super.updateConstraints()
    }
    
    func progressChanged() {
        
        if currentStep > 0 && totalSteps > 0 {
            
            if let widthConstraint = progressView.constraint(for: .width, relation: .equal) {
                _ = widthConstraint.setMultiplier(multiplier: progress)
                progressView.setNeedsLayout()
            }
            
            stepCountLabel.text = stringForLabel()
            setNeedsLayout()
        }
    }
}


