//
//  RSDCountdownDial.swift
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

@IBDesignable
public final class RSDCountdownDial: UIView {
    
    @IBInspectable
    public var dialPosition: CGFloat {
        get { return _dialPosition }
        set {
            _dialPosition = max(min(newValue, 1.0), 0.0)
            dialLayer?.strokeEnd = _dialPosition
        }
    }
    private var _dialPosition: CGFloat = 0.3
    
    public func setDialPosition(_ newValue: CGFloat, animationDuration: TimeInterval) {
        guard dialLayer != nil else {
            self.dialPosition = newValue
            return
        }
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Animate from previous position to new position
        let position = max(min(newValue, 1.0), 0.0)
        animation.fromValue = _dialPosition
        animation.toValue = position
        self.dialPosition = position
        
        dialLayer.removeAllAnimations()
        dialLayer.add(animation, forKey: "animateCircle")
    }
    
    @IBInspectable
    public var ringColor: UIColor = UIColor.rsd_dialRing {
        didSet {
            ringLayer?.strokeColor = ringColor.cgColor
        }
    }
    
    @IBInspectable
    public var ringWidth: CGFloat = 6 {
        didSet {
            ringLayer?.lineWidth = ringWidth
        }
    }
    
    @IBInspectable
    public var dialWidth: CGFloat = 24 {
        didSet {
            dialLayer?.lineWidth = dialWidth
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        dialLayer?.strokeColor = tintColor.cgColor
    }
    
    // MARK: Initialize with constraints
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layer.masksToBounds = false
        self.backgroundColor = UIColor.clear
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    // MARK: Draw the dial
    
    private var ringLayer: CAShapeLayer!
    private var dialLayer: CAShapeLayer!
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if (ringLayer == nil) {
            ringLayer = CAShapeLayer()
            ringLayer.path = createCirclePath().cgPath
            layer.addSublayer(ringLayer)
        }
        ringLayer.frame = layer.bounds
        
        if (dialLayer == nil) {
            dialLayer = CAShapeLayer()
            dialLayer.path = createCirclePath().cgPath
            layer.addSublayer(dialLayer)
        }
        dialLayer.frame = layer.bounds

        _updateLayerProperties()
    }
    
    private func _updateLayerProperties() {
        
        ringLayer?.lineWidth = ringWidth
        ringLayer?.strokeColor = ringColor.cgColor
        ringLayer?.fillColor = UIColor.clear.cgColor
        
        dialLayer?.strokeEnd = max(min(dialPosition, 1.0), 0.0)
        dialLayer?.lineWidth = dialWidth
        dialLayer?.strokeColor = tintColor.cgColor
        dialLayer?.fillColor = UIColor.clear.cgColor
    }
    
    private func createCirclePath() -> UIBezierPath {
        
        let inset: CGFloat = 0.0
        let radius = (bounds.width - inset) / 2.0
        let arcCenter = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        let startAngle = -1.0 * CGFloat.pi / 2.0
        let endAngle = 3.0 * CGFloat.pi / 2.0

        let shapePath = UIBezierPath()
        shapePath.addArc(withCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        return shapePath
    }
}
