//
//  PaletteSelectionStepViewController.swift
//  RSDCatalog
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

import UIKit
import Research
import ResearchUI

class PaletteSelectionViewController: UITableViewController {
    
    var titleLabel: UILabel!
    var headerView: UIView!
    
    var choices: [RSDColorPalette]!
    let designSystem = RSDDesignSystem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = Bundle.main.url(forResource: "ColorPalettes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = CatalogFactory.shared.createJSONDecoder()
                self.choices = try decoder.decode([RSDColorPalette].self, from: data)
            }
            catch let err {
                print("Failed to decode palette choices. \(err)")
            }
        }
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.register(TableSectionHeader.self, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorPalette", for: indexPath) as! ColorPaletteCell
        let selected = tableView.indexPathForSelectedRow == indexPath
        cell.accessoryType = selected ? .checkmark : .none
        
        let palette = choices[indexPath.item]
        
        cell.primary.backgroundColor = palette.primary.normal.color
        cell.primaryLabel.text = "\(palette.primary.swatch.name) \(palette.primary.index)"
        cell.primaryLabel.textColor = designSystem.colorRules.textColor(on: palette.primary.normal, for: .smallHeader)
        
        cell.secondary.backgroundColor = palette.secondary.normal.color
        cell.secondaryLabel.text = "\(palette.secondary.swatch.name) \(palette.secondary.index)"
        cell.secondaryLabel.textColor = designSystem.colorRules.textColor(on: palette.secondary.normal, for: .smallHeader)
        
        cell.accent.backgroundColor = palette.accent.normal.color
        cell.accentLabel.text = "\(palette.accent.swatch.name) \(palette.accent.index)"
        cell.accentLabel.textColor = designSystem.colorRules.textColor(on: palette.accent.normal, for: .smallHeader)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RSDStudyConfiguration.shared.colorPalette = choices[indexPath.item]
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let header = tableView.headerView(forSection: 0) as? TableSectionHeader {
            updateHeader(header)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        let reuseIdentifier = "TableSectionHeader"
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as! TableSectionHeader
        updateHeader(header)
        return header
    }
    
    func updateHeader(_ header: TableSectionHeader) {
        let palette = RSDStudyConfiguration.shared.colorPalette
        header.contentView.backgroundColor = palette.primary.normal.color
        header.titleLabel.textColor = designSystem.colorRules.textColor(on: palette.primary.normal, for: .smallHeader)
        header.titleLabel.text = "\(palette.primary.swatch.name) \(palette.primary.index)"
        header.secondaryDot.backgroundColor = palette.secondary.normal.color
        header.accentDot.backgroundColor = palette.accent.normal.color
    }
}

class ColorPaletteCell : UITableViewCell {
    @IBOutlet var primary: UIView!
    @IBOutlet var secondary: UIView!
    @IBOutlet var accent: UIView!
    @IBOutlet var primaryLabel: UILabel!
    @IBOutlet var secondaryLabel: UILabel!
    @IBOutlet var accentLabel: UILabel!
}

class TableSectionHeader: UITableViewHeaderFooterView {
    
    var titleLabel: UILabel!
    var secondaryDot: UIView!
    var accentDot: UIView!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Add the title label
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.darkGray
        titleLabel.textAlignment = .left
        titleLabel.rsd_alignToSuperview([.leading, .trailing], padding: 32, priority: .required)
        titleLabel.rsd_alignToSuperview([.top, .bottom], padding: 12, priority: UILayoutPriority(rawValue: 700))
        
        // Add dots
        secondaryDot = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        contentView.addSubview(secondaryDot)
        
        secondaryDot.translatesAutoresizingMaskIntoConstraints = false
        secondaryDot.rsd_makeWidth(.equal, 24)
        secondaryDot.rsd_makeHeight(.equal, 24)
        secondaryDot.rsd_alignToSuperview([.trailing], padding: 20 + 24 + 12)
        secondaryDot.rsd_alignCenterVertical(padding: 0)
        secondaryDot.layer.cornerRadius = 12
        
        accentDot = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        contentView.addSubview(accentDot)
        
        accentDot.translatesAutoresizingMaskIntoConstraints = false
        accentDot.rsd_makeWidth(.equal, 24)
        accentDot.rsd_makeHeight(.equal, 24)
        accentDot.rsd_alignToSuperview([.trailing], padding: 20)
        accentDot.rsd_alignCenterVertical(padding: 0)
        accentDot.layer.cornerRadius = 12
        
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
