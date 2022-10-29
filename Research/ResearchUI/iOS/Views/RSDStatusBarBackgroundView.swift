//
//  RSDStatusBarBackgroundView.swift
//  ResearchUI (iOS)
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

import UIKit

/// The status bar background is used on scrolling views to block the underlying view.
///
/// - seealso: `RSDTableStepViewController`
@IBDesignable
open class RSDStatusBarBackgroundView: UIView {
    
    /// The color of the overlay view that is used to normalize the status bar display.
    @IBInspectable
    open var overlayColor: UIColor = UIColor(white: 0, alpha: 0.2) {
        didSet {
            foregroundLayer.backgroundColor = overlayColor
        }
    }
    
    /// Convenience method for setting up constraints on a programatically added status bar overlay.
    public func alignToStatusBar() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.rsd_alignToSuperview([.leading, .trailing, .top], padding: 0)
        self.rsd_align([.bottom], .equal, to: superview, [.topMargin], padding: 0)
    }

    private let foregroundLayer = UIView()
    
    public init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.addSubview(foregroundLayer)
        foregroundLayer.backgroundColor = overlayColor
        foregroundLayer.translatesAutoresizingMaskIntoConstraints = false
        foregroundLayer.rsd_alignAllToSuperview(padding: 0.0)
    }
}
