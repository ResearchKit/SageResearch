//
//  RSDTaskInfoStepViewController.swift
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

/// `RSDTaskInfoStepViewController` is designed to be used to display a `RSDTaskInfoStep` either to give the user feedback
/// when a task or survey is being fetched or else to provide a consistent UI for the introduction of all tasks.
///
/// This view controller includes a default nib implementation that is included in this framework. It includes various UI
/// elements that can indicate to the user how much time is remaining in a longer-running step.  For example, this could be
/// used during a walk step to indicate to the user how long they have been walking as well as how much longer they have to
/// walk before the step is complete.
///
/// - seealso: `RSDTaskViewController.vendDefaultViewController(for:)`
///
open class RSDTaskInfoStepViewController: RSDStepViewController, UITextViewDelegate {

    /// A header for the view controller.
    @IBOutlet public var headerView: UIView?
    
    /// The title label is used to display the title for the task.
    @IBOutlet public var titleLabel: UILabel?
    
    /// The subtitle label is used to display the subtitle for the task.
    @IBOutlet public var subtitleLabel: UILabel?
    
    /// The icon image view is used to display an icon for the task.
    @IBOutlet public var iconImageView: UIImageView?
    
    /// The text view is used to display the detail text for the task. This implementation uses a `UITextView` to allow
    /// scrolling of the text included in this view.
    @IBOutlet public var textView: UITextView?
    
    /// The `RSDTaskInfoStep` object with the information to display about this task. This can be displayed while the task is loading.
    public var taskInfoStep: RSDTaskInfoStep! {
        return (self.step as! RSDTaskInfoStep)
    }
    
    // MARK: View appearance and set up
    
    /// Override `viewDidLoad()` to set up the default font, color, and position of the UI elements.
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.textView?.textContainerInset = UIEdgeInsets(top: 39, left: 43, bottom: 20, right: 43)
    }
    
    /// Override `viewWillAppear()` to set the text and images before displaying the view controller.
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Schedule and step should both be set before showing the view controller
        titleLabel?.text = taskInfoStep.taskInfo.title
        subtitleLabel?.text = taskInfoStep.taskInfo.subtitle
        if let imageSize = iconImageView?.bounds.size {
            taskInfoStep.taskInfo.imageData?.fetchImage(for: imageSize) { [weak self] (_, img) in
                self?.iconImageView?.image = img
            }
        }
        
        // Set up the step text
        self.textView?.text = taskInfoStep.taskInfo.detail
    }
    
    /// Override the skip forward action to cancel the task
    open override func skipForward() {
        self.cancel()
    }
    
    /// Override `viewDidLayoutSubviews()` to update the footer shadow that is used to indicate that there
    /// is additional information below the fold.
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateShadows()
    }
    
    // MARK: Add shadows to scroll content "under" the header and footer
    
    /// Base class implementation will call `updateShadows()`.
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateShadows()
    }
    
    /// Base class implementation will call `updateShadows()` if not decelerating.
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateShadows()
        }
    }
    
    /// Base class implementation will call `updateShadows()`.
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateShadows()
    }
    
    /// Update the footer shadow that is used to indicate that there is additional information below the fold.
    open func updateShadows() {
        guard let scrollView = self.textView else { return }
        let yBottom = scrollView.contentSize.height - scrollView.bounds.size.height - scrollView.contentOffset.y
        let hasShadow = (yBottom >= scrollView.textContainerInset.bottom)
        guard hasShadow != shouldShowFooterShadow else { return }
        shouldShowFooterShadow = hasShadow
    }
    
    private var shouldShowFooterShadow: Bool = false {
        didSet {
            self.navigationFooter?.shouldShowShadow = shouldShowFooterShadow
        }
    }
    
    
    // MARK: Initialization
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: RSDTaskInfoStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    open class var bundle: Bundle {
        return Bundle.module
    }
    
    /// Default initializer. This initializer will initialize using the `nibName` and `bundle` defined on this class.
    /// - parameter step: The step to set for this view controller.
    public init(taskInfo: RSDTaskInfoStep, parent: RSDPathComponent?) {
        super.init(nibName: type(of: self).nibName, bundle: type(of: self).bundle)
        self.stepViewModel = self.instantiateStepViewModel(for: taskInfo, with: parent)
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
