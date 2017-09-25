//
//  SRSFormItem.swift
//  SageResearchSDK
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

/**
 `SRSFormItem` is used to describe a form input and includes the data type and a possible hint to how the UI should be displayed.
 */
public protocol SRSFormItem {
    
    /**
     A short string that uniquely identifies the form item within the step. The identifier is reproduced in the results of a step result in the step history of a task result.
     */
    var identifier: String { get }
    
    /**
     A localized string that displays a short text offering a hint to the user of the data to be entered for this field.
     */
    var prompt: String? { get }
    
    /**
     A localized string that displays placeholder information for the form item.
     
     You can display placeholder text in a text field or text area to help users understand how to answer the item's question.
     */
    var placeholderText: String? { get }
    
    /**
     A Boolean value indicating whether the user can skip the step without providing an answer.
     */
    var optional: Bool { get }
    
    /**
     Validate the form item to check for any configuration that should throw an error.
     */
    func validate() throws
    
    /**
     Validation run on the
     */
    func validateResult(_ result: SRSResult) throws -> Bool
}
