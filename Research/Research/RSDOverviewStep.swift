//
//  RSDOverviewStep.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// `RSDOverviewStep` extends the `RSDUIStep` to include general overview information about an activity
/// including what permissions are required by this task. Without these preconditions, the task cannot
/// measure or collect the data needed for this task.
public protocol RSDOverviewStep : class, RSDUIStep, RSDStandardPermissionsStep {
    
    /// For an overview step, the title is readwrite.
    var title: String? { get set }
    
    /// For an overview step, the text is readwrite.
    var subtitle: String? { get set }
    
    /// For an overview step, the detail is readwrite.
    var detail: String? { get set }
    
    /// The learn more action for the task that this overview step is describing.
    var learnMoreAction: RSDUIAction? { get set }
    
    /// The icons that are used to define the list of things you will need for an active task.
    var icons: [RSDIconInfo]? { get }
}

extension RSDTask {
    
    /// Look to see if the first step in this task is an overview step and if so, return that
    /// step. Since the overview step is a class, then it can be mutated in-place without having
    /// to mutate the step navigators method of containing those steps.
    public var overviewStep: RSDOverviewStep? {
        var taskResult: RSDTaskResult = RSDTaskResultObject(identifier: self.identifier)
        let step = self.stepNavigator.step(after: nil, with: &taskResult).step
        return step as? RSDOverviewStep
    }
}
