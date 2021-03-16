//
//  Result.swift
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



/// The `BranchNodeResult` is the result created for a given level of navigation of a node tree.
public protocol BranchNodeResult : CollectionResult {

    /// The running history of the nodes that were traversed as a part of running an assessment.
    /// This will only include a subset (section) that is the path defined at this level of the
    /// overall assessment hierarchy.
    var stepHistory: [ResultData] { get set }
    
    /// The path traversed by this branch. The `nodePath` is specific to the navigation implemented
    /// on iOS and is different from the `path` implementation in the Kotlin-native framework.
    var nodePath: [String] { get set }
}

/// An `AssessmentResult` is the top-level `Result` for an assessment.
public protocol AssessmentResult : RSDTaskResult {

    /// A unique identifier for this run of the assessment. This property is defined as readwrite
    /// to allow the controller for the task to set this on the `AssessmentResult` children
    /// included in this run.
    var taskRunUUID: UUID { get set }

    /// The `versionString` may be a semantic version, timestamp, or sequential revision integer.
    var versionString: String? { get }
    
    ///  A unique identifier for a Assessment model associated with this result. This is explicitly
    /// included so that the `identifier` can be associated as per the needs of the developers and
    /// to allow for changes to the API that are not important to the researcher.
    var assessmentIdentifier: String? { get }
    
    /// A unique identifier for a schema associated with this result. This is explicitly
    /// included so that the `identifier` can be associated as per the needs of the developers and
    /// to allow for changes to the API that are not important to the researcher.
    var schemaIdentifier: String? { get }
}

