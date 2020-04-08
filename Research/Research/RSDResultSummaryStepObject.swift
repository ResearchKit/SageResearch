//
//  RSDResultSummaryStepObject.swift
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

import Foundation

/// A result summary step is used to display a result that is calculated or measured earlier in the task.
open class RSDResultSummaryStepObject: RSDActiveUIStepObject, RSDResultSummaryStep, RSDNavigationSkipRule {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case unitText, resultIdentifier, stepResultIdentifier, resultTitle, formatter
    }
    
    /// Text to display as the title above the result.
    open private(set) var resultTitle: String?
    
    /// The localized unit text to display for this step.
    open private(set) var unitText: String?
    
    /// The identifier for the step result that contains the answer result.
    open private(set) var stepResultIdentifier: String?
    
    /// The identifier for the answer result.
    open private(set) var resultIdentifier: String?
    
    /// By default, if the `resultIdentifier` is non-nil, then the step should be skipped if
    /// the result is not in the result set.
    open func shouldSkipStep(with result: RSDTaskResult?, isPeeking: Bool) -> Bool {
        guard resultIdentifier != nil else { return false }
        guard let taskResult = result else { return true }
        let value = self.answerValueAndType(from: taskResult)?.value
        return (value == nil)
    }
    
    // MARK: Initializers
    
    public required init(identifier: String, type: RSDStepType? = nil) {
        super.init(identifier: identifier, type: type)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public init(identifier: String, resultIdentifier: String, unitText: String? = nil, stepResultIdentifier: String? = nil) {
        super.init(identifier: identifier, type: nil)
        self.resultIdentifier = resultIdentifier
        self.unitText = unitText
        self.stepResultIdentifier = stepResultIdentifier
    }
    
    
    // MARK: Subclass copy and decoding.
    
    /// Default type is `.completion`.
    open override class func defaultType() -> RSDStepType {
        return .completion
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? RSDResultSummaryStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.resultTitle = self.resultTitle
        subclassCopy.unitText = self.unitText
        subclassCopy.resultIdentifier = self.resultIdentifier
        subclassCopy.stepResultIdentifier = self.stepResultIdentifier
    }
    
    /// Override the decoder per device type b/c the task may require a different set of permissions depending upon the device.
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resultTitle = try container.decodeIfPresent(String.self, forKey: .resultTitle) ?? self.resultTitle
        self.unitText = try container.decodeIfPresent(String.self, forKey: .unitText) ?? self.unitText
        self.resultIdentifier = try container.decodeIfPresent(String.self, forKey: .resultIdentifier) ?? self.resultIdentifier
        self.stepResultIdentifier = try container.decodeIfPresent(String.self, forKey: .stepResultIdentifier) ?? self.stepResultIdentifier
    }
    
    // Overrides must be defined in the base implementation
    
    override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override class func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
            "identifier": "foo",
            "type": "completion",
            "title": "Hello World!",
            "text": "Some text.",
            "resultTitle": "This is a title",
            "resultIdentifier" : "boo",
            "unitText" : "lala"
        ]
        
        return [jsonA]
    }
}
