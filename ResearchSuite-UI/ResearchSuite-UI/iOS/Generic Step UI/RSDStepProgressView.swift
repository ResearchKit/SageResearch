//
//  RSDStepProgressView.swift
//  ResearchSuite-UI
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
open class RSDStepProgressView: UIView {
    
    // These can be used to set the global color for the progress bar
    // If you want a different individual color per progress view, you will need to subclass
    open static var progressColor = UIColor.headerViewProgressBar
    open static var progressBackgroundColor = UIColor.headerViewProgressBackground
    
    /**
     The current step in the current flow
     */
    public var currentStep: Int = 0 {
        didSet { progressChanged() }
    }
    
    /**
     The total number of steps in the current flow
     */
    public var totalSteps: Int = 0 { didSet { progressChanged() } }
    
    
    private let kProgressLineHeight: CGFloat = 8.0
    
    public var progress: CGFloat {
        if totalSteps > 0 {
            return CGFloat(currentStep) / CGFloat(totalSteps)
        } else {
            return 0.0
        }
    }
    
    // MARK: View elements
    
    var progressView = UIView()
    var backgroundView = UIView()
    var stepCountLabel = UILabel()
    
    
    // MARK: Available for override
    
    /**
     The height of the actual progress bar
     */
    open func progressLineHeight() -> CGFloat {
        return currentStep > 0 && totalSteps > 0 ? kProgressLineHeight : 0.0
    }
    
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
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        self.addSubview(backgroundView)
        self.addSubview(progressView)
        self.addSubview(stepCountLabel)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        stepCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.backgroundColor = type(of: self).progressBackgroundColor
        progressView.backgroundColor = type(of: self).progressColor
        
        stepCountLabel.font = UIFont.headerViewStepCountLabel
        stepCountLabel.numberOfLines = 1
        stepCountLabel.textAlignment = .center
        stepCountLabel.textColor = UIColor.headerViewStepCountLabel
        stepCountLabel.text = stringForLabel()
        
        setNeedsUpdateConstraints()
    }
    
    open override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        backgroundView.alignToSuperview([.leading, .trailing, .top], padding: 0.0)
        backgroundView.makeHeight(.equal, progressLineHeight())
        
        progressView.alignToSuperview([.leading, .top], padding: 0.0)
        progressView.makeWidthEqualToSuperview(multiplier: progress)
        progressView.makeHeight(.equal, progressLineHeight())
        
        stepCountLabel.alignToSuperview([.leading, .trailing], padding: 0.0)
        stepCountLabel.alignBelow(view: progressView, padding: 5.0)
        stepCountLabel.makeHeight(.greaterThanOrEqual, 0.0)
        stepCountLabel.alignToSuperview([.bottomMargin], padding: 0.0)
        
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
