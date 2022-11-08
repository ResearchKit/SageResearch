//
//  RSDStatusBarBackgroundView.swift
//  ResearchUI (iOS)
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
