//
//  RSDBackgroundGradient.swift
//  ResearchUI (iOS)
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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

/// `RSDBackgroundGradient` is a UI element for adding a shadow gradient to a view.
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
