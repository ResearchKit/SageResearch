//
//  RSDCheckmarkView.swift
//  ResearchUI (iOS)
//
//  Copyright © 2016-2018 Sage Bionetworks. All rights reserved.
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

fileprivate let defaultSize: CGFloat = 122

/// A checkmark view is a simple view that draws a checkmark on a dark background.
@IBDesignable public final class RSDCheckmarkView: UIView {
    
    /// The corner radius for the checkmark. Default == -1, which will result in a circle.
    @IBInspectable public var cornerRadius: CGFloat {
        get { return _cornerRadius ?? -1 }
        set { _cornerRadius = (newValue >= 0) ? newValue : nil }
    }
    private var _cornerRadius: CGFloat?
    
    /// The color of the checkmark.
    @IBInspectable public var checkmarkColor: UIColor = UIColor.white {
        didSet {
            _shapeLayer?.strokeColor = checkmarkColor.cgColor
        }
    }
    
    /// Whether or not the checkmark is hidden.
    @IBInspectable public var checkmarkHidden: Bool {
        get {
            return _checkmarkHidden
        }
        set {
            _shapeLayer.strokeEnd = newValue ? 0 : 1
            _checkmarkHidden = newValue
        }
    }
    private var _checkmarkHidden: Bool = false
    
    /// Animate drawing the checkmark. Calling this method does nothing if the checkmark is not hidden.
    public func drawCheckmark(_ animated:Bool) {
        guard _checkmarkHidden, animated else {
            _checkmarkHidden = true
            _shapeLayer.strokeEnd = 1
            return
        }

        let timing = CAMediaTimingFunction(controlPoints: 0.180739998817444, 0, 0.577960014343262, 0.918200016021729)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.timingFunction = timing
        animation.fillMode = kCAFillModeBoth
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.3
        
        _shapeLayer.strokeEnd = 0
        _shapeLayer.add(animation, forKey: "strokeEnd")
    }
    
    fileprivate var _shapeLayer: CAShapeLayer!
    fileprivate var _circleSize: CGFloat!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        _circleSize = min(self.bounds.size.width, self.bounds.size.height)
        updateShapeLayer()
        
        self.layer.cornerRadius = _cornerRadius ?? _circleSize / 2

        self.accessibilityTraits |= UIAccessibilityTraitImage
        self.isAccessibilityElement = true
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let circleSize = min(self.bounds.size.width, self.bounds.size.height)
        if circleSize != _circleSize {
            _circleSize = circleSize
            updateShapeLayer()
        }
        _shapeLayer.frame = self.layer.bounds
        self.layer.cornerRadius = _cornerRadius ?? _circleSize / 2
    }
    
    func updateShapeLayer() {
        
        self.layer.removeAllAnimations()
        _shapeLayer?.removeFromSuperlayer()
        
        let ratio = _circleSize / defaultSize
        let path = UIBezierPath()
        path.move(to: CGPoint(x: ratio * 37, y: ratio * 65))
        path.addLine(to: CGPoint(x: ratio * 50, y: ratio * 78))
        path.addLine(to: CGPoint(x: ratio * 87, y: ratio * 42))
        path.lineCapStyle = CGLineCap.round
        path.lineWidth = min(max(2, ratio * 5), 5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = path.lineWidth
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.frame = self.layer.bounds
        shapeLayer.strokeColor = checkmarkColor.cgColor
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.strokeEnd = _checkmarkHidden ? 0 : 1
        self.layer.addSublayer(shapeLayer)
        _shapeLayer = shapeLayer
    }
}
