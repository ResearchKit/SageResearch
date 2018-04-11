//
//  MCTInstructionStepObject.swift
//  MotorControl
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

open class MCTInstructionStepObject : RSDActiveUIStepObject, RSDNavigationSkipRule {
    private enum CodingKeys: String, CodingKey {
        case isFirstRunOnly
    }
    
    /// Should this instruction step be dispalyed only when the user hasn't
    /// performed this task in a while?
    public internal(set) var isFirstRunOnly : Bool?
    
    /// Returns `true` if this step should be skipped, `false` otherwise.
    /// Default: only returns `true` if the JSON file has isFirstRunOnly explicitly set
    /// to true, and the conditions for a first run are not met. See
    /// MCTOverviewStepViewController for more on what the conditions for a first run are.
    public func shouldSkipStep(with result: RSDTaskResult?, conditionalRule: RSDConditionalRule?, isPeeking: Bool) -> Bool {
        // if self.isFirstRunOnly == nil the JSON file probably left out this field so we
        // assume that this step will always be shown
        guard (self.isFirstRunOnly ?? false),
              let isFirstRunResult = result?.findResult(with: MCTOverviewStepViewController.firstRunKey) as? RSDAnswerResult,
              let isFirstRun = isFirstRunResult.value as? Bool
            else {
            return false
        }
        
        // returns true if this isn't a first run and false otherwise.
        return !isFirstRun
    }
    
    /// Override init to also decode whether this step is a first run only instruction.
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isFirstRunOnly = try container.decodeIfPresent(Bool.self, forKey: .isFirstRunOnly)
        try super.init(from: decoder)
    }
    
    /// Override decode to also decoder whether this step is a first run only instruction.
    override open func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isFirstRunOnly = try container.decodeIfPresent(Bool.self, forKey: .isFirstRunOnly)
    }
    
    /// Require method to initialize a MCTInstructionStepObject.
    public required init(identifier: String, type: RSDStepType?) {
        super.init(identifier: identifier, type: type)
    }
}
