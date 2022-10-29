//
//  RSDSurveyRuleOperator.swift
//  Research
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

import Foundation
import JsonModel

/// List of rules creating the survey rule items.
public enum RSDSurveyRuleOperator: String, Codable, StringEnumSet {
    
    /// Survey rule for checking if the skip identifier should apply if the answer was skipped
    /// in which case the result answer value will be `nil`
    case skip               = "de"
    
    /// The answer value is equal to the `matchingAnswer`.
    case equal              = "eq"
    
    /// The answer value is *not* equal to the `matchingAnswer`.
    case notEqual           = "ne"
    
    /// The answer value is less than the `matchingAnswer`.
    case lessThan           = "lt"
    
    /// The answer value is greater than the `matchingAnswer`.
    case greaterThan        = "gt"
    
    /// The answer value is less than or equal to the `matchingAnswer`.
    case lessThanEqual      = "le"
    
    /// The answer value is greater than or equal to the `matchingAnswer`.
    case greaterThanEqual   = "ge"
    
    /// The answer value is "other than" the `matchingAnswer`. This is intended for use where the answer
    /// type is an array and the comparison is for the case where the array is evaluated as the elements
    /// are *not* included. For example, if the `matchingAnswer` is `[0,3]` and the result answer is
    /// `[2,4]` then this will evaluate to `true` and return the `skipIdentifier` because neither `2` nor
    /// `4` are in the set defined by the `matchingAnswer`.
    case otherThan          = "ot"
    
    /// The rule should always evaluate to true.
    case always
}

extension RSDSurveyRuleOperator : DocumentableStringEnum {
}
