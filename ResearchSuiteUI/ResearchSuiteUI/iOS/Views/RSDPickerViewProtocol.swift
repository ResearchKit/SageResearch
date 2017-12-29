//
//  RSDPickerViewProtocol.swift
//  ResearchSuiteUI (iOS)
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

/// `RSDPickerObserver` is an observer of changes to the picker.
@objc
public protocol RSDPickerObserver : class, NSObjectProtocol {
    @objc func pickerValueChanged(_ sender: Any)
}

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
    func mode() -> UIDatePickerMode {
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
open class RSDChoicePickerView : UIPickerView, RSDPickerViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public weak var observer: RSDPickerObserver?
    
    /// The index path associated with this picker.
    public var indexPath: IndexPath!
    
    /// The picker view data source for this view. This is a strong reference.
    public var pickerSource: RSDChoicePickerDataSource!
    
    /// The answer maps to the values for the selected rows.
    public var answer: Any? {
        get {
            var selections: [Int] = []
            for ii in 0..<self.numberOfComponents {
                let selectedRow = self.selectedRow(inComponent: ii) - 1
                guard selectedRow >= 0 else { return nil }
                selections.append(selectedRow)
            }
            return pickerSource.selectedAnswer(with: selections)
        }
        set {
            guard let selectedRows = pickerSource.selectedRows(from: newValue)
                else {
                    return
            }
            for (component, row) in selectedRows.enumerated() {
                self.selectRow(row + 1, inComponent: component, animated: false)
            }
        }
    }
    
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
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: UIPickerViewDataSource
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerSource.numberOfComponents
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerSource.numberOfRows(in: component) + 1
    }
    
    // MARK: UIPickerViewDelegate
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row > 0 else { return nil }
        guard let choice = pickerSource.choice(forRow: row - 1, forComponent: component) else { return nil }
        return choice.text
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.observer?.pickerValueChanged(self)
    }
}

/// `RSDNumberPickerView` is a `UIPickerView` that can be used to represent a picker with an associated index path.
/// This picker has a `RSDNumberPickerDataSource` as it's source.
open class RSDNumberPickerView : UIPickerView, RSDPickerViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
            let row = (decimalRow as NSNumber).intValue + 1
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
    
    public var range: Decimal {
        return pickerSource.maximum - pickerSource.minimum
    }
    
    public var interval: Decimal {
        return pickerSource.stepInterval ?? 1
    }
    
    public func decimalNumber(forRow row: Int) -> Decimal? {
        guard row > 0 else { return nil }
        return pickerSource.minimum + interval * Decimal(row - 1)
    }
    
    // MARK: UIPickerViewDataSource
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let numSteps = range / interval
        return (numSteps as NSNumber).intValue + 1
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
