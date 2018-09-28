//
//  RSDActiveUIStepObject.swift
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

/// `RSDActiveUIStepObject` extends the `RSDUIStepObject` to include a duration and commands. This is used for the
/// case where an `RSDUIStep` has an action such as "start walking" or "stop walking"; the step may also implement
/// the `RSDActiveUIStep` protocol to allow for spoken instruction.
open class RSDActiveUIStepObject : RSDUIStepObject, RSDActiveUIStep {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case duration, commands, requiresBackgroundAudio, spokenInstructions
    }

    /// The duration of time to run the step. If `0`, then this value is ignored.
    open var duration: TimeInterval = 0
    
    /// The set of commands to apply to this active step. These indicate actions to fire at the beginning and end of
    /// the step such as playing a sound as well as whether or not to automatically start and finish the step.
    ///
    /// - seealso: `RSDActiveUIStepCommand.stringMapping` for a list of the coding strings included in this framework.
    open var commands: RSDActiveUIStepCommand = .defaultCommands
    
    /// Whether or not the step uses audio, such as the speech synthesizer, that should play whether or not the user
    /// has the mute switch turned on. Default = `false`.
    open var requiresBackgroundAudio: Bool = false
    
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
    ///            "requiresBackgroundAudio": true,
    ///            "commands": ["playSoundOnStart", "vibrateOnFinish"],
    ///            "spokenInstructions" : { "start": "Start moving",
    ///                                     "10": "Keep going",
    ///                                     "halfway": "Halfway there",
    ///                                     "countdown": "5",
    ///                                     "end": "Stop moving"}
    ///         }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///         // The decoded mapping.
    ///         self.spokenInstructions = [ 0.0 : "Start moving",
    ///                                     10.0 : "Keep going",
    ///                                     15.0 : "Halfway there",
    ///                                     25.0 : "five",
    ///                                     26.0 : "four",
    ///                                     27.0 : "three",
    ///                                     28.0 : "two",
    ///                                     29.0 : "one",
    ///                                     Double.infinity : "Stop moving"]
    ///     ```
    ///
    open var spokenInstructions: [TimeInterval : String]?
    
    /// The `SpokenInstructionKeys` are specialized markers for the timing of when to speak the
    /// spoken instruction. These include keys that can be transformed into a time interval using
    /// the duration of the step to indicate the `halfway` point.
    /// - seealso: `spokenInstructions`
    public enum SpokenInstructionKeys : String, CodingKey {
        
        /// Speak the instruction at the start of the step.
        case start
        
        /// Speak the instruction at the halfway point.
        case halfway
        
        /// Speak a countdown.
        case countdown
        
        /// Speak the instruction at the end of the step.
        case end
        
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
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - type: The type of the step. Default = `RSDStepType.active`
    public required init(identifier: String, type: RSDStepType? = nil) {
        super.init(identifier: identifier, type: type ?? .active)
    }
    
    /// Initializer for setting the immutable next step identifier.
    ///
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - nextStepIdentifier: The next step to jump to. This is used where direct navigation is required.
    ///     - type: The type of the step. Default = `RSDStepType.instruction`
    public override init(identifier: String, nextStepIdentifier: String?, type: RSDStepType? = nil) {
        super.init(identifier: identifier, nextStepIdentifier: nextStepIdentifier, type: type)
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? RSDActiveUIStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.duration = self.duration
        subclassCopy.commands = self.commands
        subclassCopy.requiresBackgroundAudio = self.requiresBackgroundAudio
        subclassCopy.spokenInstructions = self.spokenInstructions
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
    ///                                     "countdown": "5",
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
        self.requiresBackgroundAudio = try container.decodeIfPresent(Bool.self, forKey: .requiresBackgroundAudio) ?? false
        self.commands = try container.decodeIfPresent(RSDActiveUIStepCommand.self, forKey: .commands) ?? .defaultCommands
        if let dictionary = try container.decodeIfPresent([String : String].self, forKey: .spokenInstructions) {
            
            // Map the json deserialized dictionary into the `spokenInstructions` dictionary.
            var countdownStart: Int?
            var instructions = dictionary.mapKeys({ (key) -> TimeInterval in
                if let specialKey = SpokenInstructionKeys(stringValue: key) {
                    switch(specialKey) {
                    case .start:
                        return 0
                    case .halfway:
                        return stepDuration / 2
                    case .end:
                        return Double.infinity
                    case .countdown:
                        guard let countdown = (dictionary[key] as NSString?)?.integerValue, countdown > 0
                            else {
                                return -1.0
                        }
                        countdownStart = countdown
                        return stepDuration - TimeInterval(countdown)
                    }
                }
                return (key as NSString).doubleValue as TimeInterval
            })
            
            // special-case handling of the countdown
            if let countdown = countdownStart {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .spellOut
                for ii in 1...countdown {
                    let timeInterval = stepDuration - TimeInterval(ii)
                    instructions[timeInterval] = numberFormatter.string(from: NSNumber(value: ii))
                }
            }
                        
            self.spokenInstructions = instructions
        }
        
        try super.init(from: decoder)
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
            "type": "active",
            "title": "Hello World!",
            "text": "Some text.",
            "duration": 30,
            "requiresBackgroundAudio": true,
            "commands": ["playSoundOnStart", "vibrateOnFinish"],
            "spokenInstructions" : [ "start": "Start moving",
                                     "10": "Keep going",
                                     "halfway": "Halfway there",
                                     "end": "Stop moving"]
        ]
        
        return [jsonA]
    }
}
