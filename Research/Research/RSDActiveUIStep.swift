//
//  RSDActiveUIStep.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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


/// `RSDActiveUIStep` extends the `RSDUIStep` to include a duration and commands. This is used for the case
/// where an `RSDUIStep` has an action such as "start walking" or "stop walking"; the step may also
/// implement the `RSDActiveUIStep` protocol to allow for spoken instruction.
public protocol RSDActiveUIStep: RSDUIStep {
    
    /// The duration of time to run the step. If `0`, then this value is ignored.
    var duration: TimeInterval { get }
    
    /// The set of commands to apply to this active step. These indicate actions to fire at the beginning
    /// and end of the step such as playing a sound as well as whether or not to automatically start and
    /// finish the step.
    var commands: RSDActiveUIStepCommand { get }
    
    /// Whether or not the step uses audio, such as the speech synthesizer, that should play whether or not
    /// the user has the mute switch turned on.
    var requiresBackgroundAudio: Bool { get }
    
    /// Should the task end early if the task is interrupted by a phone call?
    var shouldEndOnInterrupt : Bool { get }
    
    /// Localized text that represents an instructional voice prompt. Instructional speech begins when the
    /// step passes the time indicated by the given time.  If `timeInterval` is greater than or equal to
    /// `duration` or is equal to `Double.infinity`, then the spoken instruction returned should be for
    /// when the step is finished.
    ///
    /// - parameter timeInterval: The time interval at which to speak the instruction.
    /// - returns: The localized instruction to speak or `nil` if there isn't an instruction.
    func spokenInstruction(at timeInterval: TimeInterval) -> String?
}
