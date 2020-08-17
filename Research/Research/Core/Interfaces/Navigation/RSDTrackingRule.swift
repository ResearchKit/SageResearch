//
//  RSDTrackingRule.swift
//  Research
//
//  Copyright © 2016-2018 Sage Bionetworks. All rights reserved.
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


/// A tracking rule is used to track changes that are applied during a task that should be saved at the
/// end of the the overall task. By definition, these rules can mutate and should be handled using
/// pointers rather than using structs.
public protocol RSDTrackingRule : class {
    
    /// Asks the conditional rule what the identifier is for the next step to display after the given step
    /// is displayed.
    ///
    /// If *only* this step should be skipped, then return `RSDIdentifier.nextStep`. If the section should
    /// be skipped then return `RSDIdentifier.nextSection`.
    ///
    /// - parameters:
    ///     - step:      The step about to be displayed.
    ///     - result:    The current task result.
    ///     - isPeeking: Is this navigation rule being called on a result for a step that is navigating
    ///                  forward or is it a step navigator that is peeking at the next step to set up UI
    ///                  display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier of the next step to display.
    func skipToStepIdentifier(before step: RSDStep, with result: RSDTaskResult?, isPeeking: Bool) -> String?
    
    /// Asks the conditional rule what the identifier is for the next step to display after the given step
    /// is displayed.
    ///
    /// - parameters:
    ///     - step:      The step that just finished.
    ///     - result:    The current task result.
    ///     - isPeeking: Is this navigation rule being called on a result for a step that is navigating
    ///                  forward or is it a step navigator that is peeking at the next step to set up UI
    ///                  display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier of the next step.
    func nextStepIdentifier(after step: RSDStep?, with result: RSDTaskResult?, isPeeking: Bool) -> String?
}
