//
//  RSDGenericStepObject.swift
//  ResearchSuite
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

/// `RSDGenericStepObject` is a step with key/value pairs decoded from a dictionary. This is the default step returned by
/// `RSDFactory` for an unrecoginized type.
///
/// This step is intended for use as a placeholder step for decoding a step that may be defined using a customized subtype
/// or for replacing properties on an `RSDMutableStep`.
///
public struct RSDGenericStepObject : RSDGenericStep, Decodable {

    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in the results
    /// of a step history.
    public let identifier: String
    
    /// The type of the step. 
    public let stepType: RSDStepType
    
    /// The decoded dictionary.
    public let userInfo: [String : Any]
    
    private enum CodingKeys : String, CodingKey {
        case identifier, stepType = "type"
    }
    
    public init(identifier: String, stepType: RSDStepType, userInfo: [String : Any]) {
        self.identifier = identifier
        self.stepType = stepType
        self.userInfo = userInfo
    }
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    public func copy(with identifier: String) -> RSDGenericStepObject {
        return RSDGenericStepObject(identifier: identifier, stepType: self.stepType, userInfo: self.userInfo)
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - example:
    ///
    ///     ```
    ///        // Example JSON dictionary that includes two property keys for "title" and "text". These values
    ///        // will be added to the `userInfo` dictionary.
    ///        let json = """
    ///          {
    ///          "identifier": "step3",
    ///          "title": "Step 3",
    ///          "text": "Some text.",
    ///          }
    ///        """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.stepType = try container.decodeIfPresent(RSDStepType.self, forKey: .stepType) ?? "unknown"
        
        // Store any additional information to a user info dictionary
        let genericContainer = try decoder.container(keyedBy: AnyCodingKey.self)
        self.userInfo = try genericContainer.decode(Dictionary<String, Any>.self)
    }
    
    /// Instantiate a step result that is appropriate for this step. Default implementation will return a `RSDResultObject`.
    /// - returns: A result for this step.
    public func instantiateStepResult() -> RSDResult {
        return RSDResultObject(identifier: identifier, type: RSDResultType(rawValue: stepType.rawValue))
    }
    
    /// Required method. This implementation has no validation.
    public func validate() throws {
        // do nothing
    }
}
