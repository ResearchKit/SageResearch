//
//  RSDInstructionStepObject.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

open class RSDInstructionStepObject : RSDUIStepObject, RSDInstructionStep, Encodable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case spokenInstructions
    }
    
    // MARK: spoken instruction handling
    
    /// A mapping of the localized text that represents an instructional voice prompt to the time
    /// marker for speaking the instruction.
    ///
    /// - example:
    ///
    ///     ```
    ///         // Example JSON dictionary that includes a spoken instruction map.
    ///         let json = """
    ///         {
    ///            "identifier": "foo",
    ///            "type": "active",
    ///            "title": "Hello World!",
    ///            "detail": "Some text.",
    ///            "spokenInstructions" : { "start": "Look at your phone.",
    ///                                     "end": "Get ready for the next phase."}
    ///         }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///     ```
    ///
    open var spokenInstructions: [SpokenInstructionKey : String]?
    
    /// The `SpokenInstructionKey` are specialized markers for the timing of when to speak the
    /// spoken instruction. These include keys that can be transformed into a time interval using
    /// the duration of the step to indicate the `halfway` point.
    /// - seealso: `spokenInstructions`
    public enum SpokenInstructionKey : String, CodingKey {
        
        /// Speak the instruction at the start of the step.
        case start
        
        /// Speak the instruction at the end of the step.
        case end
        
        init?(timeInterval: TimeInterval) {
            switch timeInterval {
            case 0:
                self = .start
            case Double.infinity:
                self = .end
            default:
                return nil
            }
        }
    }
    
    /// Localized text that represents an instructional voice prompt. Instructional speech can be
    /// returned for `timeInterval == 0` and `timeInterval == Double.infinity` which indicate the
    /// start and end of the step.
    ///
    /// - parameter timeInterval: The time interval at which to speak the instruction.
    /// - returns: The localized instruction to speak or `nil` if there isn't an instruction.
    open func spokenInstruction(at timeInterval: TimeInterval) -> String? {
        guard let key = SpokenInstructionKey(timeInterval: timeInterval) else { return nil }
        return self.spokenInstructions?[key]
    }
    
    /// Default type is `.instruction`.
    open override class func defaultType() -> RSDStepType {
        return .instruction
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? RSDInstructionStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.spokenInstructions = self.spokenInstructions
    }
    
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
    
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let dictionary = try container.decodeIfPresent([String : String].self, forKey: .spokenInstructions) {
            self.spokenInstructions = try dictionary.mapKeys { (key) -> SpokenInstructionKey in
                guard let specialKey = SpokenInstructionKey(stringValue: key) else {
                    var codingPath = decoder.codingPath
                    codingPath.append(CodingKeys.spokenInstructions)
                    let context = DecodingError.Context(codingPath: codingPath,
                                                        debugDescription: "\(key) cannot be converted to a SpokenInstructionKey")
                    throw DecodingError.typeMismatch(SpokenInstructionKey.self, context)
                }
                return specialKey
            }
        }
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        let spokenInstructions = self.spokenInstructions?.mapKeys { $0.rawValue }
        try container.encodeIfPresent(spokenInstructions, forKey: .spokenInstructions)
    }
    
    // Overrides must be defined in the base implementation
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .spokenInstructions:
            return .init(propertyType: .primitiveDictionary(.string))
        }
    }

    override open class func jsonExamples() throws -> [[String : JsonSerializable]] {
        let jsonA: [String : JsonSerializable] = [
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "detail": "Some text.",
            "fullInstructionsOnly": true,
            "spokenInstructions" : [ "start": "Take your phone out of your pocket to review the instructions.",
                                     "end": "Put your phone back in your pocket."]
        ]

        return [jsonA]
    }
}
