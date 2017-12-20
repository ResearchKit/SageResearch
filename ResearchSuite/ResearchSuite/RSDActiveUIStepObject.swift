//
//  RSDActiveUIStepObject.swift
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

/// `RSDActiveUIStepObject` extends the `RSDUIStepObject` to include a duration and commands. This is used for the
/// case where an `RSDUIStep` has an action such as "start walking" or "stop walking"; the step may also implement
/// the `RSDActiveUIStep` protocol to allow for spoken instruction.
open class RSDActiveUIStepObject : RSDUIStepObject, RSDActiveUIStep {

    /// The duration of time to run the step. If `0`, then this value is ignored.
    public var duration: TimeInterval = 0
    
    /// The set of commands to apply to this active step. These indicate actions to fire at the beginning and end of
    /// the step such as playing a sound as well as whether or not to automatically start and finish the step.
    ///
    /// - seealso: `RSDActiveUIStepCommand.stringMapping` for a list of the coding strings included in this framework.
    public var commands: RSDActiveUIStepCommand = .defaultCommands
    
    // MARK: spoken instruction handling
    
    /// A mapping of the localized text that represents an instructional voice prompt to the time marker for speaking
    /// the instruction.
    ///
    /// The mapping is `Codable` using either `TimeInterval` values as the keys or by using the `SpokenInstructionKeys`
    /// as special keys into the mapping dictionary.
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
    ///            "text": "Some text.",
    ///            "duration": 30,
    ///            "commands": ["playSoundOnStart", "vibrateOnFinish"],
    ///            "spokenInstructions" : { "start": "Start moving",
    ///                                     "10": "Keep going",
    ///                                     "halfway": "Halfway there",
    ///                                     "end": "Stop moving"}
    ///         }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///         // The decoded mapping.
    ///         self.spokenInstructions = [ 0.0 : "Start moving",
    ///                                     10.0 : "Keep going",
    ///                                     15.0 : "Halfway there",
    ///                                     Double.infinity : "Stop moving"]
    ///     ```
    ///
    public var spokenInstructions: [TimeInterval : String]?
    
    /// The `SpokenInstructionKeys` are a specialized marker for the timing of when to speak the
    /// spoken instruction. These include keys that can be transformed into a time interval using
    /// the duration of the step to indicate the `halfway` point.
    /// - seealso: `spokenInstructions`
    public enum SpokenInstructionKeys : String, CodingKey {
        
        /// Speak the instruction at the start of the step.
        case start
        
        /// Speak the instruction at the halfway point.
        case halfway
        
        /// Speak the instruction at the end of the step.
        case end
        
        func timeInterval(with duration:TimeInterval) -> TimeInterval {
            switch(self) {
            case .start: return 0
            case .halfway: return duration / 2
            case .end: return Double.infinity
            }
        }
        
        init?(at timeInterval: TimeInterval, duration:TimeInterval) {
            if timeInterval == 0 {
                self = .start
            }
            else if timeInterval == Double.infinity || timeInterval >= duration {
                self = .end
            }
            else if timeInterval == duration / 2 {
                self = .halfway
            }
            else {
                return nil
            }
        }
    }
    
    /// Localized text that represents an instructional voice prompt. Instructional speech begins when the step
    /// passes the time indicated by the given time.  If `timeInterval` is greater than or equal to `duration`
    /// or is equal to `Double.infinity`, then the spoken instruction returned should be for when the step is finished.
    ///
    /// - parameter timeInterval: The time interval at which to speak the instruction.
    /// - returns: The localized instruction to speak or `nil` if there isn't an instruction.
    open func spokenInstruction(at timeInterval: TimeInterval) -> String? {
        var key = timeInterval
        if timeInterval >= duration && duration > 0 {
            key = Double.infinity
        }
        return self.spokenInstructions?[key]
    }
    
    // MARK: Coding (spoken instructions requires special handling and Codable auto-synthesis does not work with subclassing)
    
    private enum CodingKeys: String, CodingKey {
        case duration, commands, spokenInstructions
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - type: The type of the step. Default = `RSDStepType.active`
    public override init(identifier: String, type: RSDStepType? = nil) {
        super.init(identifier: identifier, type: type ?? .active)
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - example:
    ///
    ///     ```
    ///         // Example JSON dictionary that includes a duration, commands, and spoken instruction mapping.
    ///         let json = """
    ///         {
    ///            "identifier": "foo",
    ///            "type": "active",
    ///            "title": "Hello World!",
    ///            "text": "Some text.",
    ///            "duration": 30,
    ///            "commands": ["playSoundOnStart", "vibrateOnFinish"],
    ///            "spokenInstructions" : { "start": "Start moving",
    ///                                     "10": "Keep going",
    ///                                     "halfway": "Halfway there",
    ///                                     "end": "Stop moving"}
    ///         }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var stepDuration: TimeInterval = 0
        if let duration = try container.decodeIfPresent(Double.self, forKey: .duration) {
            self.duration = duration
            stepDuration = duration
        }
        self.commands = try container.decodeIfPresent(RSDActiveUIStepCommand.self, forKey: .commands) ?? .defaultCommands
        if let dictionary = try container.decodeIfPresent([String : String].self, forKey: .spokenInstructions) {
            
            // Map the json deserialized dictionary into the `spokenInstructions` dictionary.
            spokenInstructions = dictionary.mapKeys({ (key) -> TimeInterval in
                if let specialKey = SpokenInstructionKeys(stringValue: key) {
                    switch(specialKey) {
                    case .start: return 0
                    case .halfway: return stepDuration / 2
                    case .end: return Double.infinity
                    }
                }
                return (key as NSString).doubleValue as TimeInterval
            })
        }
        
        try super.init(from: decoder)
    }

    /// A step to merge with this step that carries replacement info. This step will look at the replacement info
    /// in the generic step and replace properties on self as appropriate.
    ///
    /// For an `RSDActiveUIStepObject`, the `duration` property can be replaced.
    open override func replace(from step: RSDGenericStep) throws { 
        self.duration = step.userInfo[CodingKeys.duration.stringValue] as? TimeInterval ?? self.duration
    }
    
    
    // Overrides must be defined in the base implementation
    
    override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = allCodingKeys()
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.duration, .commands, .spokenInstructions]
        return codingKeys
    }
    
    override class func validateAllKeysIncluded() -> Bool {
        guard super.validateAllKeysIncluded() else { return false }
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .duration:
                if idx != 0 { return false }
            case .commands:
                if idx != 1 { return false }
            case .spokenInstructions:
                if idx != 2 { return false }
            }
        }
        return keys.count == 3
    }

    override class func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
            "identifier": "foo",
            "type": "active",
            "title": "Hello World!",
            "text": "Some text.",
            "duration": 30,
            "commands": ["playSoundOnStart", "vibrateOnFinish"],
            "spokenInstructions" : [ "start": "Start moving",
                                     "10": "Keep going",
                                     "halfway": "Halfway there",
                                     "end": "Stop moving"]
        ]
        
        return [jsonA]
    }
}
