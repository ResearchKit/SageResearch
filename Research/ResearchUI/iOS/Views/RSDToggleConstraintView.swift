//
//  RSDToggleConstraintView.swift
//  BridgeApp (iOS)
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
import UIKit

@IBDesignable
open class RSDToggleConstraintView : UIView {
    
    @IBOutlet open var openView: UIView!
    @IBOutlet open var closedView: UIView!
    @IBOutlet open var openConstraints: [NSLayoutConstraint]?
    @IBOutlet open var closedConstraints: [NSLayoutConstraint]?
    
    public let animationDuration: TimeInterval = 0.2
    
    @IBInspectable public var isOpen: Bool {
        get {
            return _isOpen
        }
        set {
            _isOpen = newValue
            toggleView(animated: false)
        }
    }
    private var _isOpen: Bool = false
    
    public func setOpen(_ isOpen: Bool, animated: Bool) {
        guard isOpen != self.isOpen else { return }
        _isOpen = isOpen
        toggleView(animated: animated)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        toggleView(animated: false)
    }
    
    private func toggleView(animated: Bool) {
        guard openView != nil && closedView != nil else { return }

        openConstraints?.forEach { $0.isActive = _isOpen }
        closedConstraints?.forEach { $0.isActive = !_isOpen }
        self.setNeedsUpdateConstraints()
        
        guard animated else {
            openView.isHidden = !_isOpen
            closedView.isHidden = _isOpen
            self.openView.alpha = 1
            self.closedView.alpha = 1
            self.updateConstraintsIfNeeded()
            return
        }

        self.openView.alpha = _isOpen ? 0 : 1
        self.closedView.alpha = _isOpen ? 1 : 0
        openView.isHidden = false
        closedView.isHidden = false
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.openView.alpha = self._isOpen ? 1 : 0
            self.closedView.alpha = self._isOpen ? 0 : 1
            self.updateConstraintsIfNeeded()
        }) { (_) in
            self.openView.isHidden = !self._isOpen
            self.closedView.isHidden = self._isOpen
        }
    }
}

/// A simple button that draws a open/closed chevron that can be used to indicate whether or not
/// the details are expanded.
@IBDesignable
public final class RSDDetailsChevronButton : UIButton {
    
    public override var isSelected: Bool {
        didSet {
            chevron.setOpen(isSelected, animated: false)
        }
    }
    
    /// Set selected with animation
    public func setSelected(_ isSelected: Bool, animated: Bool) {
        chevron.setOpen(isSelected, animated: animated)
        self.isSelected = isSelected
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private var chevron: ChevronFlipView!
    
    private func commonInit() {
        let bounds = CGRect(x: 0, y: 0, width: 20, height: 10)
        chevron = ChevronFlipView(frame: bounds)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(chevron)
        chevron.rsd_alignToSuperview([.bottom, .trailing], padding: 2)
        chevron.rsd_makeWidth(.equal, bounds.width)
        chevron.rsd_makeHeight(.equal, bounds.height)
    }
}

@IBDesignable
fileprivate class ChevronFlipView : UIView {
    
    var viewDown: ChevronView!
    var viewUp: ChevronView!
    
    public private(set) var isOpen: Bool = false
    
    public func setOpen(_ isOpen: Bool, animated: Bool) {
        guard isOpen != self.isOpen else { return }
        self.isOpen = isOpen
        flip(animated: animated)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        viewDown = ChevronView(frame: self.bounds, isFlipped: false)
        self.addSubview(viewDown)
        viewDown.translatesAutoresizingMaskIntoConstraints = false
        viewDown.rsd_alignAllToSuperview(padding: 0)
        
        viewUp = ChevronView(frame: self.bounds, isFlipped: true)
        self.addSubview(viewUp)
        viewUp.translatesAutoresizingMaskIntoConstraints = false
        viewUp.rsd_alignAllToSuperview(padding: 0)
        
        flip(animated: false)
    }
    
    private func flip(animated: Bool) {
        guard animated else {
            viewUp.isHidden = self.isOpen
            viewDown.isHidden = !self.isOpen
            return
        }
        
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromBottom, .showHideTransitionViews]
        let duration = 0.2
        
        UIView.transition(with: viewUp, duration: duration, options: transitionOptions, animations: {
            self.viewUp.isHidden = self.isOpen
        })
        
        UIView.transition(with: viewDown, duration: duration, options: transitionOptions, animations: {
            self.viewDown.isHidden = !self.isOpen
        })
    }
}

@IBDesignable
fileprivate class ChevronView : UIView {
    
    public private(set) var isFlipped: Bool = false {
        didSet {
            updateShapeLayer()
        }
    }
    
    fileprivate var _shapeLayer: CAShapeLayer!
    fileprivate var _rectSize: CGSize!
    
    public init(frame: CGRect, isFlipped: Bool) {
        super.init(frame: frame)
        self.isFlipped = isFlipped
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        _rectSize = self.bounds.size
        updateShapeLayer()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clear
        let rectSize = self.bounds.size
        if rectSize != _rectSize {
            _rectSize = rectSize
            updateShapeLayer()
        }
        _shapeLayer.frame = self.layer.bounds
    }
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        _shapeLayer.strokeColor = self.tintColor.cgColor
    }
    
    private func updateShapeLayer() {
        
        self.layer.removeAllAnimations()
        _shapeLayer?.removeFromSuperlayer()
        
        let path = UIBezierPath()
        if isFlipped {
            path.move(to: CGPoint(x: 0, y: _rectSize.height))
            path.addLine(to: CGPoint(x: _rectSize.width / 2, y: 0))
            path.addLine(to: CGPoint(x: _rectSize.width, y: _rectSize.height))
        } else {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: _rectSize.width / 2, y: _rectSize.height))
            path.addLine(to: CGPoint(x: _rectSize.width, y: 0))
        }
        path.lineCapStyle = .round
        path.lineJoinStyle = .miter
        path.lineWidth = 2
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = path.lineWidth
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
        shapeLayer.frame = self.layer.bounds
        shapeLayer.strokeColor = self.tintColor.cgColor
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor = nil
        self.layer.addSublayer(shapeLayer)
        _shapeLayer = shapeLayer
    }
}
