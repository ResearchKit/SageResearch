//
//  RSDTemplateImageView.swift
//  ResearchUI (iOS)
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// The template image button is designed as a button that shows a template image within a
/// button. There are different supported style-types for the button that can be used with the
/// design system to set up the color of the button and the default tint for the image within.
@IBDesignable
open class RSDTemplateImageButton: UIButton, RSDViewDesignable {
    
    /// The corner radius for the image view. Default is -1 which will result in a circle.
    @IBInspectable public var cornerRadius: CGFloat {
        get { return _cornerRadius ?? -1 }
        set {
            _cornerRadius = (newValue >= 0) ? newValue : nil
            updateCornerRadius()
        }
    }
    fileprivate var _cornerRadius: CGFloat?
    fileprivate var _circleSize: CGFloat!
    
    /// The width of the border for views with a border. Default = 0.0
    /// The border width must be set to a value > 0 and the border color must be set to show a border.
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    /// The color of the border for views with a border. Default = nil
    /// The border width must be set to a value > 0 and the border color must be set to show a border.
    @IBInspectable public var borderColor: UIColor? = nil {
        didSet {
            self.layer.borderColor = borderColor?.cgColor
        }
    }
    
    /// Should the view display a shadow? Default = false
    @IBInspectable public var hasShadow: Bool = false {
        didSet {
            updateShadow()
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            // If the alpha component is used to set this as hidden, then don't do anything.
            guard alpha > 0.1 else { return }
            self.alpha = isEnabled ? CGFloat(1) : CGFloat(0.35)
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            // If the alpha component is used to set this as hidden, then don't do anything.
            guard alpha > 0.1 else { return }
            
            guard let colorTile = self.buttonBackground,
                let background = self.backgroundColorTile
                else {
                    // show as highlighted by lowering opacity unless alpha is used to set hidden
                    self.alpha = isHighlighted ? CGFloat(1) : CGFloat(0.8)
                    return
            }
            
            self.alpha = 1.0
            
            let designSystem = self.designSystem ?? RSDDesignSystem()
            let state: RSDControlState = isHighlighted ? .highlighted : .normal
            self.backgroundColor = designSystem.colorRules.coloredButton(on: background, forMapping: colorTile, forState: state)
        }
    }
    
    /// If the color key is set for the background of the button, then this will be used to set the
    /// highlighted and enabled states.
    public var buttonBackground : RSDColorKey? {
        didSet {
            updateColorStyle()
        }
    }
    
    /// The background color mapping that this view should use as its key. Typically, for all but the
    /// top-level views, this will be the background of the superview.
    public private(set) var backgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    public private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    public func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        self.backgroundColorTile = background
        updateColorStyle()
    }
    
    private func updateColorStyle() {
        guard let tile = self.buttonBackground else { return }
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let background: RSDColorTile = self.backgroundTile() ?? designSystem.colorRules.backgroundLight
        self.backgroundColorTile = background
        
        // Set the background to the current state. iOS 11 does not support setting the background of the
        // button based on the button state.
        let currentState: RSDControlState = isEnabled ? (isHighlighted ? .highlighted : .normal) : .disabled
        self.backgroundColor = designSystem.colorRules.coloredButton(on: background, forMapping: tile, forState: currentState)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func commonInit() {
        updateCornerRadius()
        updateShadow()
    }
    
    fileprivate func updateRatios(_ cornerRadius: CGFloat) {
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateCircleSize()
    }
}

/// The template image view is designed as an image view that shows a template image within a
/// framing view.
@IBDesignable
open class RSDTemplateImageView: UIView {
    
    /// The corner radius for the image view. Default is -1 which will result in a circle.
    @IBInspectable public var cornerRadius: CGFloat {
        get { return _cornerRadius ?? -1 }
        set {
            _cornerRadius = (newValue >= 0) ? newValue : nil
            updateCornerRadius()
        }
    }
    fileprivate var _cornerRadius: CGFloat?
    fileprivate var _circleSize: CGFloat!
    
    /// The image to display within the view.
    @IBInspectable public var image: UIImage? {
        didSet {
            _imageView?.image = self.image
        }
    }
    
    /// Inset of the image from the top. Calculated from the corner radius if not explicitly set.
    @IBInspectable public var topInset: CGFloat {
        get { return _topInset ?? -1 }
        set {
            _topInset = (newValue >= 0) ? newValue : nil
            updateCornerRadius()
        }
    }
    private var _topInset: CGFloat?
    
    /// Inset of the image from the side. Calculated from the corner radius if not explicitly set.
    @IBInspectable public var sideInset: CGFloat {
        get { return _sideInset ?? -1 }
        set {
            _sideInset = (newValue >= 0) ? newValue : nil
            updateCornerRadius()
        }
    }
    private var _sideInset: CGFloat?
    
    /// The width of the border for views with a border. Default = 0.0
    /// The border width must be set to a value > 0 and the border color must be set to show a border.
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    /// The color of the border for views with a border. Default = nil
    /// The border width must be set to a value > 0 and the border color must be set to show a border.
    @IBInspectable public var borderColor: UIColor? = nil {
        didSet {
            self.layer.borderColor = borderColor?.cgColor
        }
    }
    
    /// Should the view display a shadow? Default = false
    @IBInspectable public var hasShadow: Bool = false {
        didSet {
            updateShadow()
        }
    }
    
    /// The template image view shows an image view that is inset from the edges.
    private var _imageView: UIImageView!
    private var _imageTopInset: NSLayoutConstraint!
    private var _imageSideInset: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        _imageView = UIImageView(image: self.image)
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        _imageView.contentMode = .scaleAspectFit
        self.addSubview(_imageView)
        _imageView.rsd_alignCenterVertical(padding: 0)
        _imageView.rsd_alignCenterHorizontal(padding: 0)
        _imageTopInset = _imageView.rsd_alignToSuperview([.top], padding: 0).first
        _imageSideInset = _imageView.rsd_alignToSuperview([.leading], padding: 0).first
        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
        
        updateCircleSize()
        updateShadow()
    }
    
    fileprivate func updateRatios(_ cornerRadius: CGFloat) {
        _imageTopInset.constant = _topInset ?? _cornerRadius ?? cornerRadius / 3.0
        _imageSideInset.constant = _sideInset ?? _cornerRadius ?? cornerRadius / 3.0
        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateCircleSize()
    }
}

extension RSDTemplateImageButton : TemplateView {
}

extension RSDTemplateImageView : TemplateView {
}

/// Use a fileprivate extension to implement common behavior to the classes that do not have
/// a common inheritance tree.
fileprivate protocol TemplateView : class {
    var layer: CALayer { get }
    var bounds: CGRect { get }
    var _cornerRadius: CGFloat? { get set }
    var _circleSize: CGFloat! { get set }
    var hasShadow: Bool { get set }
    func updateRatios(_ cornerRadius: CGFloat)
}

extension TemplateView {
    
    fileprivate func updateCircleSize() {
        let circleSize = round(min(self.bounds.size.width, self.bounds.size.height))
        if _circleSize != circleSize {
            _circleSize = circleSize
            updateCornerRadius()
        }
    }
    
    fileprivate func updateCornerRadius() {
        let cornerRadius = _cornerRadius ?? _circleSize / 2.0
        self.layer.cornerRadius = cornerRadius
        updateRatios(cornerRadius)
    }
    
    fileprivate func updateShadow() {
        self.layer.shadowColor = self.hasShadow ? UIColor.black.withAlphaComponent(0.25).cgColor : UIColor.clear.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
