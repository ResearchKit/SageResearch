//
//  RSDBackgroundGradient.swift
//  ResearchUI (iOS)
//

import Foundation
import UIKit

/// `RSDBackgroundGradient` is a UI element for adding a shadow gradient to a view.
@available(*,deprecated, message: "Will be deleted in a future version.")
@IBDesignable public final class RSDBackgroundGradient : UIView, RSDViewDesignable {
    
    /// The color that the gradient begins with.
    @IBInspectable public var startColor : UIColor = RSDDesignSystem.shared.colorRules.palette.successGreen.light.color {
        didSet {
            refreshView()
        }
    }
    
    /// The color that the gradient ends with.
    @IBInspectable public var endColor : UIColor = RSDDesignSystem.shared.colorRules.palette.successGreen.normal.color {
        didSet {
            refreshView()
        }
    }
    
    /// The background color for the table cell.
    public private(set) var backgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    public private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    public func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        let colorMapping = designSystem.colorRules.mapping(for: background.color)
        self.backgroundColorTile = background
        startColor = colorMapping?.light.color ?? background.color.withSaturationMultiplier(0.5)
        endColor = background.color
        refreshView()
    }
    
    private var gradientLayer: CAGradientLayer?
    
    public init() {
        super.init(frame: CGRect.zero)
        refreshView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        refreshView()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        refreshView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        refreshView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = _calculateFrame()
    }
    
    func refreshView() {
        backgroundColor = startColor
        self.gradientLayer?.removeFromSuperlayer()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = _calculateFrame()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.locations = [0.0, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
    }
    
    private func _calculateFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
    
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer?.frame = _calculateFrame()
    }
}
