//
//  RSDImageViewCell.swift
//  ResearchUI (iOS)
//

import Foundation
import UIKit
import Research

/// `RSDImageViewCell` can be used to display images amongst the table cells.
@available(*,deprecated, message: "Will be deleted in a future version.")
@IBDesignable open class RSDImageViewCell : RSDTableViewCell {
    
    private let kVertMargin: CGFloat = 10.0
    private let kImageViewHeight: CGFloat = CGFloat(150.0).rsd_proportionalToScreenWidth()
    
    /// The image view to load into.
    @IBOutlet public var iconView: UIImageView!
    
    /// Set the label text.
    override open var tableItem: RSDTableItem! {
        didSet {
            guard let item = tableItem as? RSDImageTableItem else { return }
            imageLoader = item.imageTheme
        }
    }
    
    /// Set the image loader for this cell. This will automatically load the image or animation.
    public var imageLoader: RSDImageThemeElement? {
        didSet {
            guard _imageIdentifier != imageLoader?.imageIdentifier else {
                return
            }
            _imageIdentifier = imageLoader?.imageIdentifier
            guard let loader = imageLoader, let imageView = self.imageView else {
                // Nil out the image if the identifier is nil
                iconView.image = nil
                return
            }
            let traitCollection = self.traitCollection
            let designSystem = self.designSystem
            self.loadImage(withKey: "RSDImageViewCell",
                           using: loader,
                           into: imageView,
                           using: designSystem,
                           compatibleWith: traitCollection)
        }
    }
    private var _imageIdentifier: String?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        self.selectionStyle = .none
        
        if iconView == nil {
            iconView = UIImageView()
            iconView.contentMode = .scaleAspectFit
            contentView.addSubview(iconView)
            
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.rsd_alignToSuperview([.top, .bottom], padding: kVertMargin)
            iconView.rsd_alignCenterHorizontal(padding: 0.0)
            let height = iconView.heightAnchor.constraint(equalToConstant: kImageViewHeight)
            height.priority = UILayoutPriority(950)
            height.isActive = true
            
            setNeedsUpdateConstraints()
        }
        
        updateTintColor()
    }
    
    override open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        super.setDesignSystem(designSystem, with: background)
        updateTintColor()
    }
    
    func updateTintColor() {
        guard let colorTile = self.backgroundColorTile else { return }
        let designSystem = self.designSystem ?? RSDDesignSystem()
        self.tintColor = designSystem.colorRules.tintedIconColor(on: colorTile)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDImageViewCell : ThemeImageViewOwner {
    func themeImageIdentifier(withKey key: String) -> String? {
        return _imageIdentifier
    }
}

