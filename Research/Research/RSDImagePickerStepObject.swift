//
//  RSDImagePickerStepObject.swift
//  Research
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A concrete implementation for a `RSDImagePickerStep`.
public struct RSDImagePickerStepObject: RSDImagePickerStep, Codable {

    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, stepType = "type", sourceType, mediaTypes
    }
    
    /// The unique identifier for this step.
    public let identifier: String
    
    /// The step type is `.imagePicker` by default.
    public private(set) var stepType: RSDStepType = .imagePicker

    /// What source should be used for picking an image?
    public var sourceType: RSDImagePickerSourceType?
    
    /// What are the allowed media types?
    public var mediaTypes: [RSDImagePickerMediaType]?
    
    /// The step type for this step is a file.
    public func instantiateStepResult() -> RSDResult {
        return RSDFileResultObject(identifier: self.identifier)
    }
    
    /// Do nothing.
    public func validate() throws {
    }
}
