//
//  RSDButtonCell.swift
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
import Research

/// A protocol for setting up a delegate for the button cell.
public protocol RSDButtonCellDelegate : class {
    
    /// Called by the button cell when it is tapped.
    func didTapButton(on cell: RSDButtonCell)
}

/// `RSDButtonCell` is used to display a button.
@IBDesignable open class RSDButtonCell : RSDTableViewCell {
    
    /// The callback delegate for the cell.
    public weak var delegate: RSDButtonCellDelegate?
    
    /// Action button that is associated with this cell.
    @IBOutlet open var actionButton: UIButton!
    
    /// The target selector for tapping the button.
    @IBAction func buttonTapped() {
        self.delegate?.didTapButton(on: self)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // Hook up a target if not already done.
        if let button = actionButton, button.allTargets.count == 0 {
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
    }
}

/// Constants used by the button cell to set up standard constraints.
public protocol RSDButtonCellLayoutConstants {
    var topMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
    var sideMargin: CGFloat { get }
}

fileprivate struct DefaultRSDButtonCellLayoutConstants {
    let topMargin = CGFloat(24.0)
    let bottomMargin = CGFloat(24.0)
    let sideMargin = DefaultNavigationFooterLayoutConstants().oneButtonSideMargin
}

extension DefaultRSDButtonCellLayoutConstants : RSDButtonCellLayoutConstants {
}

@IBDesignable open class RSDModalButtonCell : RSDButtonCell {
    
    /// Override to set the content view background color to the color of the table background.
    override open var usesTableBackgroundColor: Bool {
        return true
    }
    
    /// Override the table item to set up title and icon based on the modal action.
    open override var tableItem: RSDTableItem! {
        didSet {
            guard let modalItem = tableItem as? RSDModalStepTableItem
                else {
                    return
            }
            if let buttonTitle = modalItem.action?.buttonTitle {
                actionButton.setTitle(buttonTitle, for: .normal)
            } else {
                actionButton.setTitle("", for: .normal)
            }
            if let buttonIcon = modalItem.action?.buttonImage(using: self.designSystem, compatibleWith: self.traitCollection) {
                actionButton.setImage(buttonIcon, for: .normal)
            } else {
                actionButton.setImage(nil, for: .normal)
            }
        }
    }
    
    /// The constants used to set up the cell contraints.
    static var constants: RSDButtonCellLayoutConstants = DefaultRSDButtonCellLayoutConstants()
    
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
        
        guard actionButton == nil else { return }
        
        let button = RSDRoundedButton()
        button.isSecondaryButton = true
        contentView.addSubview(button)

        let constants = RSDModalButtonCell.constants
        button.translatesAutoresizingMaskIntoConstraints = false
        button.rsd_alignToSuperview([.top], padding: constants.topMargin)
        button.rsd_alignToSuperview([.bottom], padding: constants.bottomMargin)
        button.rsd_alignToSuperview([.leading, .trailing], padding: constants.sideMargin, priority: UILayoutPriority(800.0))
        button.rsd_alignToSuperview([.centerX], padding: 0)
        
        actionButton = button
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        setNeedsUpdateConstraints()
    }
}
