//
//  RSDScrollingOverviewStepViewController.swift
//  ResearchUI (iOS)
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// The scrolling overview step view controller is a custom subclass of the overview step view controller
/// that uses a scrollview to allow showing detailed overview instructions.
open class RSDScrollingOverviewStepViewController: RSDOverviewStepViewController {

    /// The label which tells the user about the icons. Typically displays
    /// "This is what you'll need".
    @IBOutlet
    open weak var iconViewLabel: UILabel!
    
    /// The constraint that sets the scroll bar's top background view's height.
    @IBOutlet
    open weak var scrollViewBackgroundHeightConstraint: NSLayoutConstraint!
    
    /// The constraint that sets the distance between the title and the image.
    @IBOutlet
    var titleTopConstraint: NSLayoutConstraint!
    
    /// The constraint that sets the distance between the icon images and their leading/trailing edge.
    @IBOutlet
    var iconImagesLeadingConstraint: NSLayoutConstraint!
    @IBOutlet
    var iconImagesTrailingConstraint: NSLayoutConstraint!
    
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
    
    /// The button that displays the more info .
    @IBOutlet
    open var moreInformationButton: RSDUnderlinedButton!
    
    /// The constraint that sets the height of the more information button.
    @IBOutlet
    var moreInformationButtonHeight: NSLayoutConstraint!
    
    /// Overrides viewWillAppear to add an info button, display the icons, to save
    /// the current Date to UserDefaults, and to use the saved date to decide whether
    /// or not to show the full task info or an abbreviated screen.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This code assumes that either 1 or 3 icons will be displayed. In order to support
        // other values other implementations should use a UICollectionView.
        for label in iconTitles! {
            label.text = nil
        }
        
        for icon in iconImages! {
            icon.image = nil
        }
        
        if let overviewStep = self.step as? RSDOverviewStep {
            
            if let icons = overviewStep.icons {
                
                for (idx, iconInfo) in icons.enumerated() {
                    iconImages[idx].image = iconInfo.icon?.embeddedImage()
                    iconTitles[idx].text = iconInfo.title
                }
                
                // TODO: syoung 03/12/2019 Change to using a collection view.
                // When there are only 2 icons, employ this hack to center them evenly
                if (icons.count == 2) {
                    let removeIdx = 2
                    
                    // Adjust margin factor to give smaller screens more room
                    let cellWidth = self.view.frame.size.width / CGFloat(iconImages.count)
                    let marginFactor: CGFloat = (cellWidth < 125) ? 3.0 : 2.0
                    
                    // First, Adjust the leading/trailing spacing
                    iconImagesLeadingConstraint.constant = cellWidth / marginFactor
                    iconImagesTrailingConstraint.constant = cellWidth / marginFactor
                    
                    // Then, remove the third icon from the stack view
                    iconImages[removeIdx].superview?.removeFromSuperview()
                }
            }
            
            if let moreInformationAction = overviewStep.action(for: .custom("moreInformation"), on: overviewStep) {
                moreInformationButton.setTitle(moreInformationAction.buttonTitle, for: .normal)
                moreInformationButton.setImage(moreInformationAction.buttonIcon, for: .normal)
                moreInformationButton.addTarget(self, action: #selector(self.showMoreInformation), for: .touchUpInside)
            } else {
                moreInformationButton.setTitle(nil, for: .normal)
                moreInformationButtonHeight.constant = 0
            }
        }
        
        // Update the image placement constraint based on the status bar height.
        updateImagePlacementConstraints()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let shouldShowInfo = !(self.stepViewModel.rootPathComponent.shouldShowAbbreviatedInstructions ?? false)
        if shouldShowInfo {
            self._scrollToBottom()
            self._stopAnimating()
        } else if let titleLabel = self.stepTitleLabel {
            // We add a 30 pixel margin to the bottom of the title label so it isn't squished
            // up against the bottom of the scroll view.
            let frame = titleLabel.frame.offsetBy(dx: 0, dy: 30)
            // On the SE this fixes the title label being chopped off, on larger screens this is
            // expected to do nothing.
            self.scrollView.scrollRectToVisible(frame, animated: false)
        }
        _setHiddenAndScrollable(shouldShowInfo: shouldShowInfo)
    }
    
    /// Sets the height of the scroll views top background view depending on
    /// the image placement type from this step.
    open func updateImagePlacementConstraints() {
        guard let placementType = self.imageTheme?.placementType else { return }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.scrollViewBackgroundHeightConstraint.constant = (placementType == .topMarginBackground) ? statusBarHeight : CGFloat(0)
    }
    
    override open func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        
        if placement == .body {
            
            scrollView.backgroundColor = background.color
            iconViewLabel.text = Localization.localizedString("OVERVIEW_WHAT_YOU_NEED")
            iconViewLabel.textColor = self.designSystem.colorRules.textColor(on: background, for: .fieldHeader)
            iconViewLabel.font = self.designSystem.fontRules.font(for: .fieldHeader)
            
            let textColor = self.designSystem.colorRules.textColor(on: background, for: .microHeader)
            let font = self.designSystem.fontRules.font(for: .microHeader, compatibleWith: traitCollection)
            iconTitles.forEach {
                $0.textColor = textColor
                $0.font = font
            }
        }
    }
    
    /// Stops the animation view from animating.
    private func _stopAnimating() {
        /// The image view that is used to show the animation.
        let animationView = (self.navigationHeader as? RSDStepHeaderView)?.imageView
        animationView?.stopAnimating()
    }
    
    /// Sets whether the components are hidden, and whether scrolling is enabled
    /// based on whether this view should be showing the full task info or the
    /// abbreviated version.
    /// - parameters:
    ///     - shouldShowInfo     - `true` if the full task info should be shown, `false` otherwise
    private func _setHiddenAndScrollable(shouldShowInfo: Bool) {
        (self.view as? RSDStepNavigationView)?.textLabel?.isHidden = !shouldShowInfo
        self.iconViewLabel.isHidden = !shouldShowInfo
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
    
    /// Function called when more information action button is tapped
    @objc open func showMoreInformation() {
        _ = super.actionTapped(with: .custom("moreInformation"))
    }
    
    /// The function that is called when the info button is tapped.
    override open func showLearnMore() {
        let textLabel = (self.view as? RSDStepNavigationView)?.textLabel
        textLabel?.alpha = 0
        self.iconViewLabel.alpha = 0
        for label in self.iconTitles! {
            label.alpha = 0
        }
        for icon in self.iconImages! {
            icon.alpha = 0
        }
        _setHiddenAndScrollable(shouldShowInfo: true)
        UIView.animate(withDuration: 0.3, animations: {
            textLabel?.alpha = 1
            self.iconViewLabel.alpha = 1
            for label in self.iconTitles! {
                label.alpha = 1
            }
            for icon in self.iconImages! {
                icon.alpha = 1
            }
            self._scrollToBottom()
        }) { (_) in
            self.navigationFooter?.shouldShowShadow = true
        }
        
        self._stopAnimating()
    }
    
    // Makes the scroll view scroll all the way down.
    private func _scrollToBottom() {
        let frame = self.scrollView.convert(self.iconTitles[0].bounds, from: self.iconTitles[0])
        let shiftedFrame = frame.offsetBy(dx: 0, dy: 20)
        self.scrollView.scrollRectToVisible(shiftedFrame, animated: false)
    }
    
    // MARK: Initialization
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    override open class var nibName: String {
        return String(describing: RSDScrollingOverviewStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    override open class var bundle: Bundle {
        return Bundle(for: RSDScrollingOverviewStepViewController.self)
    }

}
