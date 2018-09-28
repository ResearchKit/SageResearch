//
//  RSDStepType.swift
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

/// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to customize
/// the UI.
public struct RSDStepType : RSDFactoryTypeRepresentable, Codable, Hashable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to creating a `RSDActiveUIStepObject`.
    public static let active: RSDStepType = "active"
    
    /// Defaults to creating a `RSDActiveUIStepObject` used to mark task completion.
    public static let completion: RSDStepType = "completion"
    
    /// Defaults to creating a `RSDActiveUIStepObject` used as a countdown to an active step.
    public static let countdown: RSDStepType = "countdown"
    
    /// Defaults to creating a `RSDFormUIStep`.
    public static let form: RSDStepType = "form"
    
    /// Defaults to creating a `RSDImagePickerStep`.
    public static let imagePicker: RSDStepType = "imagePicker"
    
    /// Defaults to creating a `RSDActiveUIStep`.
    public static let instruction: RSDStepType = "instruction"
    
    /// Defaults to creating a `RSDOverviewStepObject`.
    public static let overview: RSDStepType = "overview"

    /// Defaults to creating a `RSDSectionStep`.
    public static let section: RSDStepType = "section"
    
    /// Defaults to creating a `RSDSectionStep` created using a `RSDTransformerStep`.
    public static let transform: RSDStepType = "transform"
    
    /// Defaults to creating a `RSDTaskInfoStep`.
    public static let taskInfo: RSDStepType = "taskInfo"
    
    /// Defaults to creating a `RSDSubtaskStep`.
    public static let subtask: RSDStepType = "subtask"
    
    /// List of all the standard types.
    public static func allStandardTypes() -> [RSDStepType] {
        return [.active, .completion, .countdown, .form, .imagePicker, .instruction, .overview, .section, .transform, .taskInfo]
    }
}

extension RSDStepType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDStepType : RSDDocumentableStringEnum {
    static func allCodingKeys() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}
