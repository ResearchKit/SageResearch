//
//  MCTOverviewStepViewController.swift
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

open class MCTOverviewStepViewController : RSDOverviewStepViewController {
    
    public static let firstRunKey = "isFirstRun"
    
    /// The constraint that sets the scroll bar's top background view's height.
    @IBOutlet weak var scrollViewBackgroundHeightConstraint: NSLayoutConstraint!
    
    /// The image views to display the icons on.
    @IBOutlet
    open var iconImages: [UIImageView]!
    
    /// The labels to display the titles of the icons on.
    @IBOutlet
    open var iconTitles: [UILabel]!
    
    /// The button that when pressed displays the full task info.
    @IBOutlet
    open var infoButton: UIButton!
    
    /// The scroll view that contains the elements which scroll.
    @IBOutlet
    open var scrollView: UIScrollView!
    
    /// Overrides viewWillAppear to add an info button, display the icons, to save
    /// the current Date to UserDefaults, and to use the saved date to decide whether
    /// or not to show the full task info or an abbreviated screen.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateImagePlacementConstraints()
        // This code assumes that either 1 or 3 icons will be displayed. In order to support
        // other values other implementations should use a UICollectionView.
        for label in iconTitles! {
            label.text = nil
        }
        
        for icon in iconImages! {
            icon.image = nil
        }
        
        if let icons = (self.step as? MCTOverviewStepObject)?.icons {
            for (idx, iconInfo) in icons.enumerated() {
                iconImages[idx].image = iconInfo.icon.embeddedImage()
                iconTitles[idx].text = iconInfo.title
            }
        }
        // If this is the first time the activity has been done or it has been more than
        // a month since the last run we show the task info, otherwise we show a smaller
        // screen and provide an info button in case the user wants to see the info.
        let defaults = UserDefaults.standard
        let timestampKey = "\(taskController.taskPath.identifier)_lastRun"
        let lastRun = defaults.object(forKey: timestampKey) as? Date
        let isFirstRun = lastRun == nil
            || lastRun! < Date(timeIntervalSinceNow: -2592000)
        _setIsFirstRunResult(isFirstRun: isFirstRun)
        defaults.set(Date(), forKey: timestampKey)
        if  isFirstRun {
            /// The image view that is used to show the animation.
            var animationView: UIImageView? {
                return (self.navigationHeader as? RSDStepHeaderView)?.imageView
            }
            animationView?.stopAnimating()
        }
        
        _setHiddenAndScrollable(shouldShowInfo: isFirstRun)
    }
    
    /// Sets the height of the scroll views top background view depending on
    /// the image placement type from this step.
    open func updateImagePlacementConstraints() {
        guard let placementType = self.themedStep?.imageTheme?.placementType else { return }
        self.scrollViewBackgroundHeightConstraint.constant = placementType == .topMarginBackground ? self.statusBarBackgroundView!.bounds.height : CGFloat(0)
    }
    
    /// Adds a result for whether or not this run represents a "first run", A "first run"
    /// occurs anytime the user has never run the task before, or hasn't run the task in
    /// one month.
    private func _setIsFirstRunResult(isFirstRun: Bool) {
        var stepResult = RSDAnswerResultObject(identifier: MCTOverviewStepViewController.firstRunKey, answerType: .boolean)
        stepResult.value = isFirstRun
        self.taskController.taskPath.appendStepHistory(with: stepResult)
    }
    
    /// Sets whether the components are hidden, and whether scrolling is enabled
    /// based on whether this view should be showing the full task info or the
    /// abbreviated version.
    /// - parameters:
    ///     - shouldShowInfo     - `true` if the full task info should be shown, `false` otherwise
    private func _setHiddenAndScrollable(shouldShowInfo: Bool) {
        (self.view as? RSDStepNavigationView)?.textLabel?.isHidden = !shouldShowInfo
        for label in self.iconTitles! {
            label.isHidden = !shouldShowInfo
        }
        for icon in self.iconImages! {
            icon.isHidden = !shouldShowInfo
        }
        self.scrollView?.isScrollEnabled = shouldShowInfo
        self.infoButton?.isHidden = shouldShowInfo
        self.navigationFooter?.shouldShowShadow = shouldShowInfo
    }
    
    /// The function that is called when the info button is tapped.
    @IBAction
    private func infoButtonTapped(_ sender: UIButton) {
        let textLabel = (self.view as? RSDStepNavigationView)?.textLabel
        textLabel?.alpha = 0
        for label in self.iconTitles! {
            label.alpha = 0
        }
        for icon in self.iconImages! {
            icon.alpha = 0
        }
        _setHiddenAndScrollable(shouldShowInfo: true)
        UIView.animate(withDuration: 0.3, animations: {
            textLabel?.alpha = 1
            for label in self.iconTitles! {
                label.alpha = 1
            }
            for icon in self.iconImages! {
                icon.alpha = 1
            }
            self.scrollView?.setContentOffset(CGPoint(x: 0, y: self.scrollView!.contentSize.height - self.scrollView!.bounds.height), animated: false)
        }) { (_) in
            self.navigationFooter?.shouldShowShadow = true
        }
    }
}
