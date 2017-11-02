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

open class RSDActiveUIStepObject : RSDUIStepObject, RSDActiveUIStep {

    public var duration: TimeInterval = 0
    public var spokenInstructions: [TimeInterval : String]?
    public var commands: RSDActiveUIStepCommand = .defaultCommands
    
    // MARK: spoken instruction handling
    
    public enum SpokenInstructionKeys : String, CodingKey {
        case start, halfway, end
        
        public func timeInterval(with duration:TimeInterval) -> TimeInterval {
            switch(self) {
            case .start: return 0
            case .halfway: return duration / 2
            case .end: return Double.infinity
            }
        }
        
        public init?(at timeInterval: TimeInterval, duration:TimeInterval) {
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
    
    public override init(identifier: String, type: String? = nil) {
        super.init(identifier: identifier, type: type ?? RSDFactory.StepType.active.rawValue)
    }
    
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

    open override func replace(from step: RSDGenericStep) throws { 
        self.duration = step.userInfo?[CodingKeys.duration.stringValue] as? TimeInterval ?? self.duration
    }
    
//    TODO: syoung 11/01/2017 Implement encoding if we ever decide we need to support it.
//    open override func encode(to encoder: Encoder) throws {
//        try super.encode(to: encoder)
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(duration, forKey: .duration)
//        try container.encode(commands, forKey: .commands)
//        if let spokenInstructions = self.spokenInstructions {
//            let dictionary = spokenInstructions.mapKeys { SpokenInstructionKeys(at: $0, duration: self.duration)?.rawValue ?? "\($0)" }
//            try container.encode(dictionary, forKey: .spokenInstructions)
//        }
//    }
}
