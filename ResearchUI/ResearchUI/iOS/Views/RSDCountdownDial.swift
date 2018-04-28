//
//  RSDCountdownDial.swift
//  ResearchStack2UI
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

/// `RSDProgressIndicator` is an animatable abstract view that marks progress. Override the `progressLayer` property
/// to show progress using a shape layer. See `RSDCountdownDial` for an example implementation.
@IBDesignable
open class RSDProgressIndicator: UIView {
    
    /// The progress of the indicator.
    @IBInspectable
    open var progress: CGFloat {
        get { return _progress }
        set {
            _progress = max(min(newValue, 1.0), 0.0)
            if let progressLayer = self.progressLayer {
                progressLayer.removeAllAnimations()
                progressLayer.strokeEnd = _progress
            }
        }
    }
    private var _progress: CGFloat = 0.3
    
    /// Set the progress position for the view using an animation duration.
    ///
    /// - parameters:
    ///     - newValue: The new value of the progress at the end of the animation.
    ///     - animationDuration: The duration of the animation.
    open func setProgressPosition(_ newValue: CGFloat, animationDuration: TimeInterval) {
        guard let progressLayer = self.progressLayer else {
            self.progress = newValue
            return
        }
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Animate from previous position to new position
        let position = max(min(newValue, 1.0), 0.0)
        animation.fromValue = _progress
        animation.toValue = position
        
        self.progress = position
        progressLayer.add(animation, forKey: "animateCircle")
    }
    
    /// Override to implement progress layer.
    open var progressLayer: CAShapeLayer! {
        return nil
    }
}

/// `RSDCountdownDial` shows a circular dial indicator.
/// - seealso: `RSDActiveStepViewController`
@IBDesignable
public final class RSDCountdownDial: RSDProgressIndicator, RSDViewColorStylable {
    
    /// The color of the circular ring that shows the track of the progress indicator.
    @IBInspectable
    public var progressColor: UIColor = UIColor.rsd_dialRing {
        didSet {
            dialLayer?.strokeColor = progressColor.cgColor
        }
    }
    
    /// Should the element display with a light style of progress bar and label for use on a dark
    /// background, or with a dark style of progress bar for use on a light background?
    @IBInspectable
    open var usesLightStyle: Bool = false {
        didSet {
            updateColorStyle()
        }
    }
    
    private func updateColorStyle() {
        let ringColor = usesLightStyle ? UIColor.rsd_dialRingBackgroundLightStyle : UIColor.rsd_dialRingBackground
        ringLayer?.strokeColor = ringColor.cgColor
    }
    
    /// The width of the circular ring that shows the track of the progress indicator.
    @IBInspectable
    public var ringWidth: CGFloat = 4 {
        didSet {
            ringLayer?.lineWidth = ringWidth
        }
    }
    
    /// The width of the dial (progress indicator).
    /// - note: The color of the dial is set using the `tintColor` property.
    @IBInspectable
    public var dialWidth: CGFloat = 18 {
        didSet {
            dialLayer?.lineWidth = dialWidth
        }
    }
    
    /// Override `tintColorDidChange()` to update the color of the progress indicator dial.
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
        self.backgroundColor = self.usesLightStyle ? UIColor.rsd_dialInnerBackgroundLightStyle : UIColor.rsd_dialInnerBackground
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    // MARK: Draw the dial
    
    /// Override to implement progress layer.
    public override var progressLayer: CAShapeLayer! {
        return dialLayer
    }
    
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
        
        layer.masksToBounds = false
        backgroundColor = UIColor.clear
        
        ringLayer?.lineWidth = ringWidth
        ringLayer?.strokeColor = UIColor.rsd_dialRingBackground.cgColor
        ringLayer?.fillColor = UIColor.clear.cgColor
        
        dialLayer?.strokeEnd = progress
        dialLayer?.lineWidth = dialWidth
        dialLayer?.strokeColor = progressColor.cgColor
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
