//
//  RSDTaskInfo.swift
//  Research
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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


/// `RSDTaskInfo` includes information to display about a task before the task is fetched.
/// This can be used to display a collection of tasks and only load the task when selected
/// by the participant.
public protocol RSDTaskInfo : RSDCopyWithIdentifier, ContentNode {
    
    /// A short string that uniquely identifies the task.
    var identifier: String { get }
    
    /// The primary text to display for the task in a localized string.
    var title: String? { get }
    
    /// The subtitle text to display for the task in a localized string.
    var subtitle: String? { get }
    
    /// Additional detail text to display for the task. Generally, this would be displayed
    /// while the task is being fetched.
    var detail: String? { get }
    
    /// The estimated number of minutes that the task will take. If `0`, then this is ignored.
    var estimatedMinutes: Int { get }
    
    /// An icon image that can be used for displaying the choice.
    var imageData: RSDImageData? { get }
    
    /// Optional schema info to pass with the task info for this task.
    var schemaInfo: RSDSchemaInfo? { get }
    
    /// The resource transformer on `RSDTaskInfo` can be used in cases where the transformer is
    /// loaded from a resource by the task info (when decoded). If the task info is used as the
    /// information container for a **step** that loads the task using a service to fetch the
    /// task, then this pointer can be `nil`.
    var resourceTransformer : RSDTaskTransformer? { get }
}

public extension RSDTaskInfo {
    var footnote: String? { nil }
}
