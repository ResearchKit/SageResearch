//
//  MCTInstructionStepViewController.swift
//  MotorControl
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

import Foundation

public protocol MCTHandStepController : RSDStepController {
    /// isFirstAppearance should be `true` if this is the first time the view has appeared, and
    /// `false` otherwise
    var isFirstAppearance: Bool { get }
    
    /// Should get the navigationHeader for this view.
    var navigationHeader: RSDNavigationHeaderView? { get }
}

extension MCTHandStepController {
    
    /// Returns the randomized order that the hands steps will execute in from the task result.
    public func handOrder() -> [MCTHandSelection]? {
        var taskPath = self.taskController.taskPath
        repeat {
            if let handSelectionResult = taskPath?.result.findResult(with: MCTHandSelectionDataSource.selectionKey) as? RSDCollectionResult,
               let handOrder : [String] = handSelectionResult.findAnswerResult(with: MCTHandSelectionDataSource.handOrderKey)?.value as? [String] {
               return handOrder.compactMap{ MCTHandSelection(rawValue: $0) }
            }
        
            taskPath = taskPath?.parentPath
        } while (taskPath != nil)
        
        return nil
    }
    
    /// Returns which hand is being used for this step.
    public func whichHand() -> MCTHandSelection? {
        if let hand = MCTHandSelection(rawValue: self.taskController.taskPath.identifier) {
            return hand
        } else if let handOrder = self.handOrder() {
            return handOrder.first
        }
        
        return nil
    }
    
    
    /// Flips the image if this view is for the right hand. Only flips the first time the view appears.
    public func updateImage() {
        guard let direction = self.whichHand(),
              self.isFirstAppearance,
              direction == .right else { return }
        self.navigationHeader?.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
}


open class MCTInstructionStepViewController : RSDStepViewController, MCTHandStepController {
    
    /// The constraint for the topBackground image placement.
    @IBOutlet weak var topBackgroundContraint: NSLayoutConstraint!
    
    /// The contraint for the topMarginBackground image placement.
    @IBOutlet weak var topMarginBackgroundConstraint: NSLayoutConstraint!
    
    /// Override viewWillAppear to update the label text, and image placement constraints.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateLabelText()
        self.updateImagePlacementConstraints()
        self.updateImage()
        self.statusBarBackgroundView?.backgroundColor = UIColor.clear
    }
    
    /// Chooses between topMarginBackgroundConstraint and topBackground constraint depending on
    /// the image placement type from this step.
    open func updateImagePlacementConstraints() {
        guard let placementType = self.themedStep?.imageTheme?.placementType else { return }
        switch placementType {
        case .topMarginBackground:
            topMarginBackgroundConstraint.isActive = true
            topBackgroundContraint.isActive = false
        default:
            topBackgroundContraint.isActive = true
            topMarginBackgroundConstraint.isActive = false
        }
    }
    
    /// Sets the title and text labels' text to a version of their text localized with
    /// a string from the body direction that goes first. Expected is either ("LEFT" or "RIGHT").
    open func updateLabelText() {
        guard let direction = self.whichHand()?.rawValue.uppercased(),
              let titleFormat = self.uiStep?.title,
              let textFormat = self.uiStep?.text
              else {
               return
        }
        // TODO rkolmos 04/09/2018 localize and standardize with java implementation
        self.stepTitleLabel?.text = String.localizedStringWithFormat(titleFormat, direction)
        self.stepTextLabel?.text = String.localizedStringWithFormat(textFormat, direction)
    }
    
    /// Flips the image if this view is for the right hand. Only flips the first time the view appears.
    open func updateImage() {
        guard let direction = self.whichHand(),
              isFirstAppearance,
              direction == .right else { return }
        self.navigationHeader?.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
}
