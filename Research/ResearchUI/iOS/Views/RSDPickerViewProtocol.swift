//
//  RSDPickerViewProtocol.swift
//  ResearchUI (iOS)
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/// `RSDPickerViewProtocol` is a protocol for an input view that can be used to pick an answer.
@objc
public protocol RSDPickerViewProtocol : class, NSObjectProtocol {
    
    /// The index path associated with this picker.
    @objc var indexPath: IndexPath! { get set }
    
    /// The answer from the picker view that maps to the input field.
    @objc var answer: Any? { get set }
    
    /// The observer to alert when there is a change in the selected value.
    @objc weak var observer: RSDPickerObserver? { get set }
}

/// `RSDPickerObserver` is an observer of changes to the picker.
@objc
public protocol RSDPickerObserver : class, NSObjectProtocol {
    @objc func pickerValueChanged(_ sender: Any)
}

/// `RSDDatePicker` is a date picker that stores a pointer to the index path with which it is associated.
public class RSDDatePicker : UIDatePicker, RSDPickerViewProtocol {
    
    /// The observer of this picker
    public weak var observer: RSDPickerObserver?
    
    /// The index path associated with this picker.
    public var indexPath: IndexPath!
    
    /// The current date.
    public var answer: Any? {
        get {
            return self.date
        }
        set {
            guard let date = newValue as? Date else { return }
            self.date = date
        }
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - pickerSource: The picker source used to set up the picker.
    ///     - indexPath: The index path associated with this picker.
    public init(pickerSource: RSDDatePickerDataSource, indexPath: IndexPath) {
        super.init(frame: .zero)
        self.indexPath = indexPath
        self.answer = pickerSource.defaultDate
        self.datePickerMode = pickerSource.datePickerMode.mode()
        self.maximumDate = pickerSource.maximumDate
        self.minimumDate = pickerSource.minimumDate
        self.minuteInterval = pickerSource.minuteInterval ?? 1
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.addTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)
    }
    
    @objc private func pickerValueChanged(_ sender: Any) {
        self.observer?.pickerValueChanged(self)
    }
}

extension RSDDatePickerMode {
    
    /// The `UIDatePickerMode` that maps to this picker mode.
    func mode() -> UIDatePicker.Mode {
        switch self {
        case .date:
            return .date
        case .time:
            return .time
        case .dateAndTime:
            return .dateAndTime
        }
    }
}

/// `RSDChoicePickerView` is a `UIPickerView` that can be used to represent a picker with an associated index path.
/// This picker has a `RSDChoicePickerDataSource` as it's source. This implementation only supports text choices.
open class RSDChoicePickerView : UIPickerView, RSDPickerViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate, RSDViewDesignable {

    /// The observer of this picker
    public weak var observer: RSDPickerObserver?
    
    /// The index path associated with this picker.
    public var indexPath: IndexPath!
    
    /// The picker view data source for this view. This is a strong reference.
    public var pickerSource: RSDChoicePickerDataSource!
    
    /// Default initializer.
    /// - parameters:
    ///     - pickerSource: The picker source used to set up the picker.
    ///     - indexPath: The index path associated with this picker.
    public init(pickerSource: RSDChoicePickerDataSource, indexPath: IndexPath) {
        super.init(frame: .zero)
        self.indexPath = indexPath
        self.pickerSource = pickerSource
        self.delegate = self
        self.dataSource = self
    }
    
    /// Required initialized.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// The answer maps to the values for the selected rows.
    public var answer: Any? {
        get {
            let components = self.pickerComponents()
            let selections = components.compactMap { (pickerComponent) -> Int? in
                let selectedRow = self.selectedRow(inComponent: pickerComponent) - rowOffset
                return selectedRow >= 0 ? selectedRow : nil
            }
            guard selections.count == components.count else { return nil }
            return pickerSource.selectedAnswer(with: selections)
        }
        set {
            let components = self.pickerComponents()
            if hasSeparator {
                let componentsCount = self.numberOfComponents
                for ii in components {
                    let separatorComponent = ii + 1
                    if separatorComponent < componentsCount {
                        self.selectRow(0, inComponent: separatorComponent, animated: false)
                    }
                }
            }
            guard let selectedRows = pickerSource.selectedRows(from: newValue ?? pickerSource.defaultAnswer)
                else {
                    return
            }
            for (componentIndex, row) in selectedRows.enumerated() {
                guard componentIndex < components.count else { return }
                let selectedRow = row + rowOffset
                let selectedComponent = components[componentIndex]
                self.selectRow(selectedRow, inComponent: selectedComponent, animated: false)
            }
        }
    }
    
    /// Returns `true` if the picker source has a separator between fields.
    open var hasSeparator: Bool {
        return pickerSource.separator?.count ?? 0 > 0
    }
    
    /// Returns the row offset for the picker source. By default, this equals `1` to allow
    /// showing an empty row, *unless* there is a non-nil default answer in which case this
    /// will return `0`.
    open var rowOffset: Int {
        return pickerSource.defaultAnswer == nil ? 1 : 0
    }
    
    /// Override super to return the number of components returned by the picker source
    /// because this is the `UIPickerViewDataSource` for itself and therefore calling this
    /// method can cause returning `0` or an infinite loop of wacky madness.
    open override var numberOfComponents: Int {
        if hasSeparator {
            return pickerSource.numberOfComponents * 2 - 1
        } else {
            return pickerSource.numberOfComponents
        }
    }
    
    /// Override super to return the number of rows for each component returned by the picker
    /// source because this is the `UIPickerViewDataSource` for itself and therefore calling this
    /// method can cause returning `0` or an infinite loop of wacky madness.
    open override func numberOfRows(inComponent component: Int) -> Int {
        guard let pickerComponent = transformedComponent(component) else {
            return hasSeparator ? 1 : 0
        }
        return pickerSource.numberOfRows(in: pickerComponent) + rowOffset
    }
    
    /// Transform the component into the components for the picker source, or return `nil`
    /// if this is a separator row.
    func transformedComponent(_ component: Int) -> Int? {
        guard let idx = pickerComponents().firstIndex(of: component) else { return nil }
        return idx
    }
    
    /// Returns the array of components that map to the components of the picker.
    /// This is needed because the separator is displayed using its own row.
    /// By doing so, the separator will appear stationary while the rows spin to
    /// either side of the separator.
    func pickerComponents() -> [Int] {
        let strideBy = hasSeparator ? 2 : 1
        return Array(stride(from: 0, to: self.numberOfComponents, by: strideBy))
    }
    
    /// Is the given component a separator component?
    /// - parameter component: The component in this picker view.
    func isSeparatorComponent(_ component: Int) -> Bool {
        return transformedComponent(component) == nil
    }
    
    /// Returns the choice associated with the given row.
    /// - parameters:
    ///     - row: The row in this picker view.
    ///     - component: The component in this picker view.
    open func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        let pickerRow = row - rowOffset
        guard let pickerComponent = transformedComponent(component), pickerRow >= 0 else {
            return nil
        }
        return pickerSource.choice(forRow: pickerRow, forComponent: pickerComponent)
    }
    
    // MARK: UIPickerViewDataSource
    
    /// returns the number of 'columns' to display.
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.numberOfComponents
    }
    
    /// returns the # of rows in each component.
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.numberOfRows(inComponent: component)
    }
    
    // MARK: UIPickerViewDelegate
    
    /// Returns the text value associated with the given row. If this is a separator, this will return the
    /// `pickerSource.separator`. Otherwise, this method will return the choice text for the choice returned
    /// by the picker.
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard !isSeparatorComponent(component) else {
            return hasSeparator ? pickerSource.separator : nil
        }
        guard let choice = choice(forRow: row, forComponent: component) else {
            return nil
        }
        return choice.text
    }
    
    /// Return a view to use for this picker. By default, this method returns a label that is
    /// aligned with the components center aligned.
    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? instantiateLabel(for: component)
        label.text = self.pickerView(self, titleForRow: row, forComponent: component)
        return label
    }

    /// Returns the width of the component. By default, the width is calculated based on the width
    /// of the text.
    open func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        guard let width = _rowWidth[component] else {
            updateSize()
            return _rowWidth[component] ?? 0
        }
        return width
    }
    
    /// Returns the height for the row. By default, the height of the largest component is used for
    /// all the components.
    open func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if _rowHeight == 0 { updateSize() }
        return _rowHeight
    }
    
    /// Let the observer know that the picker value has changed.
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.observer?.pickerValueChanged(self)
    }

    // MARK: Component view management
    
    /// Instantiate a label for the given component.
    open func instantiateLabel(for component: Int) -> UILabel {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let background = self.backgroundColorTile ?? designSystem.colorRules.backgroundLight        
        let label = UILabel()
        label.font = designSystem.fontRules.baseFont(for: .largeHeader)
        label.textColor = designSystem.colorRules.textColor(on: background, for: .largeHeader)
        let isFirst = (component == 0)
        let isLast = (component + 1 == numberOfComponents)
        if numberOfComponents == 1 || !(isFirst || isLast) {
            label.textAlignment = .center
        } else {
            label.textAlignment = isLast ? .right : .left
        }
        return label
    }
    
    private func updateSize() {
        guard pickerSource != nil else { return }
        
        let componentsCount = self.numberOfComponents
        let maxSize = CGSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude)
        
        for component in 0..<componentsCount {
            
            // Calculate the width and height
            let label = self.instantiateLabel(for: component)
            let font = label.font
            let numRows = self.numberOfRows(inComponent: component)
            var biggest = CGSize.zero
            for row in 0..<numRows {
                guard let text = self.pickerView(self, titleForRow: row, forComponent: component) else { continue }
                let size = (text as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font : font as Any], context: nil)
                biggest = CGSize(width: max(size.width, biggest.width), height: max(size.height, biggest.height))
            }
            
            // Update the size constraints for each
            let margins = label.layoutMargins
            let widthMargins = isSeparatorComponent(component) ? 0 : margins.left + margins.right
            _rowWidth[component] = ceil(biggest.width) + widthMargins
            _rowHeight = max(_rowHeight, ceil(biggest.height) + margins.top + margins.bottom)
        }
    }
    private var _rowWidth: [Int: CGFloat] = [:]
    private var _rowHeight: CGFloat = 0
    
    // MARK: Design System
    
    public private(set) var backgroundColorTile: RSDColorTile?
    
    public private(set) var designSystem: RSDDesignSystem?
    
    public func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        self.backgroundColorTile = background
    }
}

/// `RSDNumberPickerView` is a `UIPickerView` that can be used to represent a picker with an associated index path.
/// This picker has a `RSDNumberPickerDataSource` as it's source.
open class RSDNumberPickerView : UIPickerView, RSDPickerViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate {
    
    /// The observer of this picker
    public weak var observer: RSDPickerObserver?
    
    /// The index path associated with this picker.
    public var indexPath: IndexPath!
    
    /// The picker view data source for this view. This is a strong reference.
    public var pickerSource: RSDNumberPickerDataSource!
    
    /// The answer maps to the values for the selected rows.
    public var answer: Any? {
        get {
            let selectedRow = self.selectedRow(inComponent: 0)
            return decimalNumber(forRow: selectedRow)
        }
        set {
            // Check that the answer is a number in range
            let number: Decimal
            if let decimal = newValue as? Decimal {
                number = decimal
            } else if let num = (newValue as? NSNumber) ?? (newValue as? RSDJSONNumber)?.jsonNumber() {
                number = Decimal(num.doubleValue)
            } else {
                number = .nan
            }
            guard number != .nan, number <= pickerSource.maximum, number >= pickerSource.minimum else {
                self.selectRow(0, inComponent: 0, animated: false)
                return
            }
            
            // get the nearest decimal
            let decimalRow = (number - pickerSource.minimum) / interval
            let row = Int(round((decimalRow as NSNumber).doubleValue)) + 1
            self.selectRow(row, inComponent: 0, animated: false)
        }
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - pickerSource: The picker source used to set up the picker.
    ///     - indexPath: The index path associated with this picker.
    public init(pickerSource: RSDNumberPickerDataSource, indexPath: IndexPath) {
        super.init(frame: .zero)
        self.indexPath = indexPath
        self.pickerSource = pickerSource
        self.delegate = self
        self.dataSource = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var range: Decimal {
        return abs(pickerSource.maximum - pickerSource.minimum)
    }
    
    private var interval: Decimal {
        return pickerSource.stepInterval ?? 1
    }
    
    private func decimalNumber(forRow row: Int) -> Decimal? {
        guard row > 0 else { return nil }
        return pickerSource.minimum + interval * Decimal(row - 1)
    }
    
    // MARK: UIPickerViewDataSource
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let numSteps = range / interval
        let numValueRows = numSteps + 1 // n steps means n + 1 values
        return Int(round((numValueRows as NSNumber).doubleValue)) + 1 // add a row for "no choice selected" at row 0
    }
    
    // MARK: UIPickerViewDelegate
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let number = decimalNumber(forRow: row) else { return nil }
        return pickerSource.numberFormatter.string(from: number as NSNumber)
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.observer?.pickerValueChanged(self)
    }
}
