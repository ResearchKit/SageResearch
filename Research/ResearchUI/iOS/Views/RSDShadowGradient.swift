//
//  RSDShadowGradient.swift
//  BridgeAppSDK
//

import UIKit

/// `RSDShadowGradient` is a UI element for adding a shadow gradient to a view.
@IBDesignable open class RSDShadowGradient : UIView {
    
    /// The color of the shadow that is drawn as the background of this view
    @IBInspectable var shadowColor : UIColor = UIColor.black {
        didSet {
            commonInit()
        }
    }
    
    /// The alpha value (0.0 to 1.0) that the bototm part of the gradient will be at.
    @IBInspectable var bottomAlpha : CGFloat = CGFloat(0.25) {
        didSet {
            commonInit()
        }
    }
    
    /// The alpha value (0.0 to 1.0) that the top part of the gradient will be at.
    @IBInspectable var topAlpha : CGFloat = CGFloat(0.0) {
        didSet {
            commonInit()
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    
    public init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    func commonInit() {
        backgroundColor = UIColor.clear
        gradientLayer.frame = self.bounds
        
        let bottomColor = shadowColor.withAlphaComponent(bottomAlpha).cgColor
        let topColor = shadowColor.withAlphaComponent(topAlpha).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        
        if layer.sublayers?.count ?? 0 == 0 {
            layer.addSublayer(gradientLayer)
        }
    }
    
    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = self.bounds
    }
}
