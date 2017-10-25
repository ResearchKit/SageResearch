//
//  RSDTaskInfoViewController.swift
//  ResearchSuiteUI
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

open class RSDTaskInfoViewController: UIViewController, RSDStepController, UITextViewDelegate {

    

    open class var nibName: String {
        return String(describing: RSDTaskInfoViewController.self)
    }
    
    open class var bundle: Bundle {
        return Bundle(for: RSDTaskInfoViewController.self)
    }
    
    @IBOutlet public var headerView: UIView?
    @IBOutlet public var titleLabel: UILabel?
    @IBOutlet public var subtitleLabel: UILabel?
    @IBOutlet public var iconImageView: UIImageView?
    
    @IBOutlet public var textView: UITextView?
    
    @IBOutlet public var footerView: UIView?
    @IBOutlet public var startButton: RSDRoundedButton?
    @IBOutlet public var cancelButton: RSDUnderlinedButton?
    
    open var textColor: UIColor = UIColor.appTextDark
    
    public var taskController: RSDTaskController!
    public var taskInfo: RSDTaskInfo!
    
    open var isForwardEnabled: Bool {
        return taskController.isForwardEnabled
    }
    
    public init(taskInfo: RSDTaskInfo) {
        super.init(nibName: type(of: self).nibName, bundle: type(of: self).bundle)
        self.taskInfo = taskInfo
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView?.backgroundColor = UIColor.appBackgroundDark
        self.titleLabel?.textColor = UIColor.appTextLight
        self.subtitleLabel?.textColor = UIColor.appTextLight
        
        self.view.backgroundColor = UIColor.appBackgroundLight
        self.textView?.backgroundColor = UIColor.clear
        self.footerView?.backgroundColor = UIColor.appBackgroundLight
        
        self.startButton?.shadowColor = UIColor.roundedButtonBackgroundDark
        self.startButton?.shadowColor = UIColor.roundedButtonShadowDark
        self.startButton?.titleColor = UIColor.roundedButtonTextLight
        
        self.cancelButton?.textColor = UIColor.underlinedButtonTextDark
        
        self.textView?.textColor = UIColor.appTextDark
        self.textView?.textContainerInset = UIEdgeInsets(top: 39, left: 43, bottom: 20, right: 43)
        
        // for iPad, increase text font sizes by 50%
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            if let titleFont = self.titleLabel?.font {
                self.titleLabel!.font = titleFont.withSize(titleFont.pointSize * 1.5)
            }
            if let subtitleFont = self.subtitleLabel?.font {
                self.subtitleLabel!.font = subtitleFont.withSize(subtitleFont.pointSize * 1.5)
            }
            if let textFont = self.textView?.font {
                self.textView!.font = textFont.withSize(textFont.pointSize * 1.5)
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Schedule and step should both be set before showing the view controller
        titleLabel?.text = taskInfo.title
        subtitleLabel?.text = taskInfo.subtitle
        if let imageSize = iconImageView?.bounds.size {
            taskInfo.fetchIcon(for: imageSize) { [weak self] (img) in
                self?.iconImageView?.image = img
            }
        }
        
        // Set up the step text
        self.textView?.text = taskInfo.detail
        // TODO: add copyright with smaller font syoung 10/17/2017
        
        // Enable start button if the task is loaded
        self.startButton?.isEnabled = self.isForwardEnabled
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateShadows()
    }
    
    @IBAction public func startTapped() {
        goForward()
    }
    
    @IBAction public func cancelTapped() {
        cancel()
    }
    
    public func goForward() {
        self.taskController.goForward()
    }
    
    public func goBack() {
        if self.taskController.hasStepBefore {
            self.taskController.goBack()
        }
    }
    
    public func skipForward() {
        self.taskController.goForward()
    }
    
    public func cancel() {
        self.taskController.handleTaskCancelled()
    }
    
    public func didFinishLoading() {
        self.startButton?.isEnabled = true
    }
    
    // MARK: Add shadows to scroll content "under" the header and footer
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateShadows()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateShadows()
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateShadows()
    }
    
    open func updateShadows() {
        guard let scrollView = self.textView else { return }
        let yBottom = scrollView.contentSize.height - scrollView.bounds.size.height - scrollView.contentOffset.y
        let hasShadow = (yBottom >= scrollView.textContainerInset.bottom)
        guard hasShadow != shouldShowFooterShadow else { return }
        shouldShowFooterShadow = hasShadow
    }
    
    private var shouldShowFooterShadow: Bool = false {
        didSet {
            if shouldShowFooterShadow {
                footerView?.layer.shadowOffset = CGSize(width: 0, height: 1)
                footerView?.layer.shadowRadius = 3.0
                footerView?.layer.shadowColor = UIColor.black.cgColor
                footerView?.layer.shadowOpacity = 0.8
            }
            else {
                footerView?.layer.shadowOpacity = 0.0
            }
        }
    }
}
