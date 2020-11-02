//
//  RSDImageViewCell.swift
//  ResearchUI (iOS)
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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
import Research

/// `RSDImageViewCell` can be used to display images amongst the table cells.
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

extension RSDImageViewCell : ThemeImageViewOwner {
    func themeImageIdentifier(withKey key: String) -> String? {
        return _imageIdentifier
    }
}

