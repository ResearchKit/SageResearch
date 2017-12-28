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

/// `RSDPickerViewProtocol` is a protocol for an input view that can be used to pick an answer.
public protocol RSDPickerViewProtocol : class, NSObjectProtocol {
    
    /// The index path associated with this picker.
    var indexPath: IndexPath! { get set }
    
    /// The answer from the picker view that maps to the input field.
    var answer: Any? { get set }
}

/// `RSDDatePicker` is a date picker that stores a pointer to the index path with which it is associated.
open class RSDDatePicker : UIDatePicker, RSDPickerViewProtocol {
    
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
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
