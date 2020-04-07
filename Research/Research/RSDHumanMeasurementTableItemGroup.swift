//
//  RSDHumanMeasurementTableItemGroup.swift
//  Research
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

/// An item group for entering data that is a human-measurement in localized units appropriate to the
/// size-range of a human (adult, child, infant).
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
open class RSDHumanMeasurementTableItemGroup : RSDInputFieldTableItemGroup {
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        guard case .measurement(let measurementType, let measurementSize) = inputField.dataType else {
            fatalError("Cannot instantiate a measurement type item group without a base data type")
        }
        
        var tableItems: [RSDTableItem]!
        var answerType: RSDAnswerResultType!
        var hint: RSDFormUIHint = uiHint
        
        switch measurementType {
        case .height:
            let tableItem = RSDHeightInputTableItem(rowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, measurementSize: measurementSize)
            answerType = tableItem.answerType
            hint = tableItem.uiHint
            tableItems = [tableItem]
            
        case .weight:
            let tableItem = RSDMassInputTableItem(rowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, measurementSize: measurementSize)
            answerType = tableItem.answerType
            hint = tableItem.uiHint
            tableItems = [tableItem]
            
        case .bloodPressure:
            answerType = RSDAnswerResultType(baseType: .string, sequenceType: nil, formDataType: inputField.dataType)
            let textFieldOptions: RSDTextFieldOptions = inputField.textFieldOptions ?? {
                var options = RSDTextFieldOptionsObject()
                options.textValidator = try! RSDRegExValidatorObject(regExPattern: "^\\s*\\d{2,3}\\s{0,1}\\/\\s{0,1}\\d{2,3}\\s*$")
                options.invalidMessage = Localization.localizedString("VALIDATION_ERROR_BLOOD_PRESSURE")
                return options
                }()
            let tableItem = RSDTextInputTableItem(rowIndex: beginningRowIndex, inputField: inputField, uiHint: hint, answerType: answerType, textFieldOptions: textFieldOptions)
            tableItems = [tableItem]
        }
        
        super.init(beginningRowIndex: beginningRowIndex, items: tableItems, inputField: inputField, uiHint: hint, answerType: answerType)
    }
}
