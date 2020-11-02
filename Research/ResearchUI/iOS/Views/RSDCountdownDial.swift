//
//  RSDCountdownDial.swift
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
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
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
public final class RSDCountdownDial: RSDProgressIndicator, RSDViewDesignable {

    /// Point to the design system.
    public var customDesignSystem: RSDDesignSystem?
    
    /// The color of the circular ring that shows the track of the progress indicator.
    @IBInspectable
    public var progressColor: UIColor = RSDDesignSystem.shared.colorRules.palette.accent.normal.color {
        didSet {
            dialLayer?.strokeColor = progressColor.cgColor
        }
    }
    
    /// The color of the unfilled circular ring.
    @IBInspectable
    public var ringColor: UIColor = RSDDesignSystem.shared.colorRules.palette.grayScale.veryLightGray.color {
        didSet {
            ringLayer?.strokeColor = ringColor.cgColor
        }
    }
    
    /// Whether or not this countdown dial's inner color uses light-style UI elements.
    @IBInspectable
    public var usesLightStyle: Bool {
        get {
            return _usesLightStyle
        }
        set {
            _usesLightStyle = newValue
            updateColorStyle()
        }
    }
    private var _usesLightStyle: Bool = false
    
    /// The color of the inside of the circle.
    @IBInspectable
    public var innerColor: UIColor {
        get {
            return _innerColor
        }
        set {
            _innerColor = newValue
            updateColorStyle()
        }
    }
    private var _innerColor: UIColor = UIColor.clear
    
    @IBInspectable
    public var hasShadow: Bool = true {
        didSet {
            ringLayer?.shadowOpacity = hasShadow ? 1.0 : 0
        }
    }

    /// If the colorStyle is set, then this will determine the inner color and light style and will
    /// override any colors set by the storyboard or nib. This value is `nil` by default and can only be set
    /// programatically.
    public var colorStyle : RSDColorStyle? {
        didSet {
            updateColorStyle()
        }
    }
    
    /// The background color mapping that this view should use as its key. Typically, for all but the
    /// top-level views, this will be the background of the superview.
    public var backgroundColorTile: RSDColorTile? {
        return RSDColorTile(_innerColor, usesLightStyle: _usesLightStyle)
    }
    
    /// The design system for this component.
    public private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    public func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        updateColorStyle(designSystem, background)
    }
    
    private func updateColorStyle(_ ds: RSDDesignSystem? = nil, _ bk: RSDColorTile? = nil) {
        let designSystem = ds ?? RSDDesignSystem()
        let background = bk ?? RSDColorTile(_innerColor, usesLightStyle: _usesLightStyle)
        let colorRules = designSystem.colorRules.progressDial(on: background,
                                                              style: self.colorStyle,
                                                              innerColor: self.innerColor,
                                                              usesLightStyle: self.usesLightStyle)
        if ds != nil {
            self.ringColor = colorRules.unfilled
            self.progressColor = colorRules.filled
            _innerColor = colorRules.inner.color
            _usesLightStyle = colorRules.inner.usesLightStyle
            ringLayer?.fillColor = innerColor.cgColor
        }
        
        func recursiveLabelUpdate(_ view: UIView) {
            view.subviews.forEach {
                if let label = $0 as? UILabel {
                    // TODO: syoung 07/03/2019 Revisit setting the label color to match the font size.
                    label.textColor = designSystem.colorRules.textColor(on: colorRules.inner, for: .largeNumber)
                }
                else if let stackView = $0 as? UIStackView {
                    recursiveLabelUpdate(stackView)
                }
            }
        }
        recursiveLabelUpdate(self)
        
        self.recursiveSetDesignSystem(designSystem, with: colorRules.inner)
    }
    
    /// The width of the circular ring that shows the track of the progress indicator.
    @IBInspectable
    public var ringWidth: CGFloat = 10 {
        didSet {
            ringLayer?.lineWidth = ringWidth
        }
    }
    
    /// The width of the dial (progress indicator).
    @IBInspectable
    public var dialWidth: CGFloat = 10 {
        didSet {
            dialLayer?.lineWidth = dialWidth
        }
    }
    
    // MARK: Initialize with constraints
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateColorStyle()
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        layer.masksToBounds = false
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    // MARK: Draw the dial
    
    /// Override to implement progress layer.
    public override var progressLayer: CAShapeLayer! {
        return dialLayer
    }
    
    private var ringLayer: CAShapeLayer!
    private var dialLayer: CAShapeLayer!
    private var _rect: CGRect?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.layer.bounds
        if _rect == nil || !bounds.equalTo(_rect!) {
            ringLayer?.removeFromSuperlayer()
            dialLayer?.removeFromSuperlayer()
            _rect = bounds
    
            let path = createCirclePath().cgPath
        
            ringLayer = CAShapeLayer()
            ringLayer.path = path
            layer.insertSublayer(ringLayer, at: 0)
            ringLayer.frame = bounds
            
            dialLayer = CAShapeLayer()
            dialLayer.path = path
            layer.addSublayer(dialLayer)
            dialLayer.frame = bounds
        }

        _updateLayerProperties()
    }
    
    private func _updateLayerProperties() {
        
        layer.masksToBounds = false
        
        ringLayer?.lineWidth = ringWidth
        ringLayer?.fillColor = innerColor.cgColor
        ringLayer?.strokeColor = ringColor.cgColor
        
        if innerColor != UIColor.clear, let ringLayer = ringLayer, hasShadow {
            ringLayer.shadowPath = ringLayer.path
            ringLayer.shadowColor = UIColor.black.cgColor
            ringLayer.shadowOpacity = 1
            ringLayer.shadowRadius = 10
            ringLayer.shadowOffset = CGSize(width: 0, height: 0)
            ringLayer.compositingFilter = "multiplyBlendMode"
        }
        
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
