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
        set {
            _cornerRadius = (newValue >= 0) ? newValue : nil
            self.layer.cornerRadius = _cornerRadius ?? _circleSize / 2
        }
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
    
    /// Override background color to instead set a layer that can be inset.
    override public var backgroundColor: UIColor? {
        get {
            return _backgroundColor
        }
        set {
            _backgroundColor = newValue
            _backgroundLayer?.backgroundColor = _backgroundColor?.cgColor
            super.backgroundColor = UIColor.clear
        }
    }
    private var _backgroundColor: UIColor?
    
    @IBInspectable public var backgroundInset: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
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
        animation.fillMode = CAMediaTimingFillMode.both
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.3
        
        _shapeLayer.strokeEnd = 0
        _shapeLayer.add(animation, forKey: "strokeEnd")
    }
    
    fileprivate var _shapeLayer: CAShapeLayer!
    fileprivate var _backgroundLayer: CALayer!
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
        
        _backgroundLayer = CALayer()
        _backgroundLayer.bounds = self.bounds
        _backgroundLayer.backgroundColor = self.backgroundColor?.cgColor
        self.layer.addSublayer(_backgroundLayer!)
        
        _circleSize = min(self.bounds.size.width, self.bounds.size.height)
        updateShapeLayer()
        
        let defaultCornerRadius = _circleSize / 2
        if _cornerRadius == nil {
            _cornerRadius = defaultCornerRadius
        }
        self.layer.cornerRadius = _cornerRadius ?? defaultCornerRadius

        self.accessibilityTraits.formUnion(.image)
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
        self.layer.cornerRadius = _cornerRadius ?? 0
        
        _backgroundLayer.frame = self.layer.bounds.insetBy(dx: self.backgroundInset, dy: self.backgroundInset)
        _backgroundLayer.cornerRadius = (self.layer.cornerRadius < _circleSize / 2) ?
            self.layer.cornerRadius : _backgroundLayer.frame.width / 2
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
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.frame = self.layer.bounds
        shapeLayer.strokeColor = checkmarkColor.cgColor
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.strokeEnd = _checkmarkHidden ? 0 : 1
        self.layer.addSublayer(shapeLayer)
        _shapeLayer = shapeLayer
    }
}

/// A table cell that displays using a checkbox.
@IBDesignable public class RSDCheckboxTableCell : RSDTableViewCell {
    
    fileprivate let buttonView: RSDCheckboxButtonView
    
    /// The corner radius the checkbox.
    @IBInspectable public var cornerRadius: CGFloat {
        get { return buttonView.cornerRadius }
        set { buttonView.cornerRadius = newValue }
    }
    
    /// The background color of the checkbox when selected.
    @IBInspectable public var selectedColor : UIColor {
        get { return buttonView.selectedColor }
        set { buttonView.selectedColor = newValue }
    }
    
    /// The border color of the checkbox when selected.
    @IBInspectable public var selectedBorderColor : UIColor {
        get { return buttonView.selectedBorderColor }
        set { buttonView.selectedBorderColor = newValue }
    }
    
    override public var isSelected: Bool {
        didSet {
            buttonView.isSelected = self.isSelected
        }
    }
    
    override public var tableItem: RSDTableItem! {
        didSet {
            guard let item = tableItem as? RSDChoiceTableItem else { return }
            buttonView.label.text = item.choice.text
            isSelected = item.selected
        }
    }
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.buttonView = RSDCheckboxButtonView(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.buttonView = RSDCheckboxButtonView(frame: .zero)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.contentView.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.rsd_alignToSuperview([.top, .bottom], padding: 12)
        buttonView.rsd_alignToSuperview([.leading, .trailing], padding: 24)
        buttonView.isUserInteractionEnabled = false
        buttonView.isSelected = self.isSelected
    }
}

/// A table cell that displays using a checkbox.
@IBDesignable public class RSDRadioButtonTableCell : RSDCheckboxTableCell {
    
    override public var cornerRadius: CGFloat {
        get { return checkboxHeight / 2.0 }
        set { }
    }
    
    override fileprivate func commonInit() {
        super.commonInit()
        buttonView.cornerRadius = checkboxHeight / 2.0
        buttonView.viewChecked.checkmarkHidden = true
        buttonView.viewChecked.backgroundInset = 3.0
    }
}

@IBDesignable public class RSDRadioButton : UIButton, RSDViewDesignable {
    fileprivate let buttonView: RSDCheckboxButtonView
    
    /// The background color of the checkbox when selected.
    @IBInspectable public var selectedColor : UIColor {
        get { return buttonView.selectedColor }
        set { buttonView.selectedColor = newValue }
    }
    
    /// The border color of the checkbox when selected.
    @IBInspectable public var selectedBorderColor : UIColor {
        get { return buttonView.selectedBorderColor }
        set { buttonView.selectedBorderColor = newValue }
    }
    
    public override init(frame: CGRect) {
        self.buttonView = RSDCheckboxButtonView(frame: frame)
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.buttonView = RSDCheckboxButtonView(frame: .zero)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        self.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.rsd_alignAllToSuperview(padding: 0)
        buttonView.isUserInteractionEnabled = false
        
        self.setTitleColor(UIColor.clear, for: .normal)
        self.contentEdgeInsets = .zero
        buttonView.label?.text = self.currentTitle
        buttonView.isSelected = self.isSelected
        
        buttonView.cornerRadius = checkboxHeight / 2.0
        buttonView.viewChecked.checkmarkHidden = true
        buttonView.viewChecked.backgroundInset = 3.0
        
        self.imageView?.removeFromSuperview()
    }
    
    override public func setTitle(_ title: String?, for state: UIControl.State) {
        self.setTitleColor(UIColor.clear, for: .normal)
        super.setTitle(title, for: state)
        buttonView.label?.text = self.currentTitle
    }
    
    override public var isSelected: Bool {
        didSet {
            buttonView.isSelected = self.isSelected
        }
    }
    
    public var backgroundColorTile: RSDColorTile? {
        return self.buttonView.backgroundColorTile
    }
    
    public var designSystem: RSDDesignSystem? {
        return self.buttonView.designSystem
    }
    
    public func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.buttonView.setDesignSystem(designSystem, with: background)
    }
}


/// A button that displays using a checkbox.
@IBDesignable public final class RSDCheckboxButton : UIButton {
    
    fileprivate let buttonView: RSDCheckboxButtonView
    
    /// The corner radius the checkbox.
    @IBInspectable public var cornerRadius: CGFloat {
        get { return buttonView.cornerRadius }
        set { buttonView.cornerRadius = newValue }
    }
    
    /// The background color of the checkbox when selected.
    @IBInspectable public var selectedColor : UIColor {
        get { return buttonView.selectedColor }
        set { buttonView.selectedColor = newValue }
    }
    
    /// The border color of the checkbox when selected.
    @IBInspectable public var selectedBorderColor : UIColor {
        get { return buttonView.selectedBorderColor }
        set { buttonView.selectedBorderColor = newValue }
    }
    
    public override init(frame: CGRect) {
        self.buttonView = RSDCheckboxButtonView(frame: frame)
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.buttonView = RSDCheckboxButtonView(frame: .zero)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        self.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.rsd_alignAllToSuperview(padding: 0)
        buttonView.isUserInteractionEnabled = false
        
        self.setTitleColor(UIColor.clear, for: .normal)
        self.contentEdgeInsets = .zero
        buttonView.label?.text = self.currentTitle
        buttonView.isSelected = self.isSelected
    }
    
    override public func setTitle(_ title: String?, for state: UIControl.State) {
        self.setTitleColor(UIColor.clear, for: .normal)
        super.setTitle(title, for: state)
        buttonView.label?.text = self.currentTitle
    }
    
    override public var isSelected: Bool {
        didSet {
            buttonView.isSelected = self.isSelected
        }
    }
}

fileprivate let borderWidth: CGFloat = 1
fileprivate let checkboxHeight: CGFloat = 32

fileprivate class RSDCheckboxButtonView : UIView, RSDViewDesignable {
    
    fileprivate var checkboxContainer: UIView!
    fileprivate var viewChecked: RSDCheckmarkView!
    fileprivate var viewUnchecked: UncheckedView!
    fileprivate var label: UILabel!
    
    /// The corner radius the checkbox. Default == 3.0
    var cornerRadius: CGFloat = 3.0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    /// The background color of the checkbox when selected.
    var selectedColor : UIColor = RSDStudyConfiguration.shared.colorPalette.primary.normal.color {
        didSet {
            viewChecked.backgroundColor = selectedColor
        }
    }
    
    /// The border color of the checkbox when selected.
    var selectedBorderColor : UIColor = RSDStudyConfiguration.shared.colorPalette.primary.light.color {
        didSet {
            viewChecked.layer.borderColor = selectedBorderColor.cgColor
        }
    }
    
    /// Is this checkbox for a control that is selected?
    var isSelected: Bool = false {
        didSet {
            refreshViews()
        }
    }
    
    /// The background color for the table cell.
    fileprivate var backgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    fileprivate var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        self.backgroundColorTile = background
        
        let selected = designSystem.colorRules.checkboxButton(on: background, isSelected: true)
        let notSelected = designSystem.colorRules.checkboxButton(on: background, isSelected: false)
        
        self.selectedColor = selected.background
        self.selectedBorderColor = selected.border
        self.viewChecked.checkmarkColor = selected.checkmark
        self.viewUnchecked.borderColor = notSelected.border
        self.viewUnchecked.backgroundColor = notSelected.background
        
        updateColorAndFont()
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
        
        checkboxContainer = UIView(frame: CGRect(x: 0, y: 0, width: checkboxHeight, height: checkboxHeight))
        self.addSubview(checkboxContainer)
        checkboxContainer.translatesAutoresizingMaskIntoConstraints = false
        checkboxContainer.rsd_makeWidth(.equal, checkboxHeight)
        checkboxContainer.rsd_makeHeight(.equal, checkboxHeight)
        checkboxContainer.rsd_alignToSuperview([.leading, .top], padding: 0)
        
        viewUnchecked = UncheckedView(frame: self.bounds)
        checkboxContainer.addSubview(viewUnchecked)
        viewUnchecked.translatesAutoresizingMaskIntoConstraints = false
        viewUnchecked.rsd_alignAllToSuperview(padding: 0)
        
        viewChecked = RSDCheckmarkView(frame: self.bounds)
        checkboxContainer.addSubview(viewChecked)
        viewChecked.translatesAutoresizingMaskIntoConstraints = false
        viewChecked.rsd_alignAllToSuperview(padding: 0)
        viewChecked.layer.borderWidth = borderWidth
        viewChecked.backgroundColor = self.tintColor
        
        label = UILabel(frame: CGRect(x: 42, y: 0, width: 100, height: 32))
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.rsd_alignToSuperview([.trailing], padding: 10, priority: .required)
        label.rsd_alignRightOf(view: checkboxContainer, padding: 10, priority: .required)

        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.clipsToBounds = false
        
        // Align label to allow word wrapping, with centered text if single line.
        label.rsd_align([.centerY], .equal, to: checkboxContainer, [.centerY], padding: 0, priority: .defaultHigh)
        label.rsd_align([.top], .greaterThanOrEqual, to: checkboxContainer, [.top], padding: 0, priority: .required)
        label.rsd_align([.bottom], .lessThanOrEqual, to: self, [.bottom], padding: 0, priority: .required)
        checkboxContainer.rsd_alignToSuperview([.bottom], padding: 0, priority: .defaultHigh)
        
        // hide the title label
        checkboxContainer.isUserInteractionEnabled = false
        
        viewChecked.backgroundColor = selectedColor
        viewChecked.layer.borderColor = selectedBorderColor.cgColor
        
        updateCornerRadius()
        updateColorAndFont()
        refreshViews()
    }
    
    private func updateCornerRadius() {
        viewUnchecked.cornerRadius = self.cornerRadius
        viewChecked.cornerRadius = self.cornerRadius
        self.layer.cornerRadius = self.cornerRadius
    }
    
    private func updateColorAndFont() {
        let background = self.backgroundColorTile ?? RSDColorTile(UIColor.white, usesLightStyle: false)
        let designSystem = self.designSystem ?? RSDDesignSystem()
        
        label.font = designSystem.fontRules.font(for: .body, compatibleWith: traitCollection)
        label.textColor = designSystem.colorRules.textColor(on: background, for: .body)
        checkboxContainer.backgroundColor = background.color
        self.backgroundColor = background.color
    }
    
    private func refreshViews() {
        viewUnchecked?.isHidden = self.isSelected
        viewChecked?.isHidden = !self.isSelected
    }
}

@IBDesignable
fileprivate class UncheckedView : UIView {
    
    fileprivate var borderColor: UIColor = RSDStudyConfiguration.shared.colorPalette.grayScale.lightGray.color {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    /// The corner radius for the checkmark box.
    fileprivate var cornerRadius: CGFloat = 3 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    var _shadowLayer: CAShapeLayer!
    var _shadowBounds: CGRect?
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        
        if _shadowBounds != self.bounds {
            _shadowBounds = self.bounds
            resetInnerShadow()
        }
    }
    
    /// define function to add inner shadow
    private func resetInnerShadow() {
        
        _shadowLayer?.removeFromSuperlayer()
        
        let shadowSize: CGFloat = 2.0
        
        // define and set a shaow layer
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = bounds
        shadowLayer.shadowColor = borderColor.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        shadowLayer.shadowOpacity = 0.5
        shadowLayer.shadowRadius = shadowSize
        shadowLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        // define shadow path
        let shadowPath = CGMutablePath()
        
        // define outer rectangle to restrict drawing area
        let insetRect = bounds.insetBy(dx: -shadowSize * 2.0, dy: -shadowSize * 2.0)
        
        // define inner rectangle for mask
        let innerFrame: CGRect = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        
        // add outer and inner rectangle to shadow path
        shadowPath.addRect(insetRect)
        shadowPath.addRect(innerFrame)
        
        // set shadow path as show layer's
        shadowLayer.path = shadowPath
        
        // add shadow layer as a sublayer
        self.layer.addSublayer(shadowLayer)
        
        // hide outside drawing area
        self.clipsToBounds = true
        
        _shadowLayer = shadowLayer
    }
}
