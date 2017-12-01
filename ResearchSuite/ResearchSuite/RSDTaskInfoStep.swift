//
//  RSDTaskInfoStep.swift
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


/// A completion handler for fetching a task using the task info `fetchTask()` method.
public typealias RSDTaskFetchCompletionHandler = (RSDTaskInfoStep, RSDTask?, Error?) -> Void

/// The possible errors thrown when fetching a task.
public enum RSDTaskFetchError : Error {
    
    /// Unknown error
    case unknown
    
    /// The user's device is offline and a network connect is required to fetch the task.
    case offline
}

/// `RSDTaskInfoStep` is a reference interface for information about the task. This includes information that can
/// be displayed in a table or collection view before starting the task as well as information that is displayed
/// while the task is being fetched in the case where the task is not fetched using an embedded resource or via
/// a hardcoded task.
public protocol RSDTaskInfoStep : RSDStep {
    
    /// A short string that uniquely identifies the task.
    var identifier: String { get }
    
    /// The primary text to display for the task in a localized string.
    var title: String? { get }
    
    /// The subtitle text to display for the task in a localized string.
    var subtitle: String? { get }
    
    /// Additional detail text to display for the task.
    var detail: String? { get }
    
    /// Copyright information for the task.
    var copyright: String? { get }
    
    /// The estimated number of minutes that the task will take. If `0`, then this is ignored.
    var estimatedMinutes: Int { get }
    
    /// The estimated time to fetch the task. This can be used by the UI to determine whether or not to
    /// display a loading state while fetching the task. If `0` then the task is assumed to be cached on the device.
    var estimatedFetchTime: TimeInterval { get }
    
    /// Fetch the task for this task info. Use the given factory to transform the task.
    ///
    /// - parameters:
    ///     - factory:     The factory to use for creating the task and steps.
    ///     - callback:    The callback with the task or an error if the task failed, run on the main thread.
    func fetchTask(with factory: RSDFactory, callback: @escaping RSDTaskFetchCompletionHandler)
    
    /// An icon image that can be used for displaying the task.
    ///
    /// - parameters:
    ///     - size:        The size of the image to return.
    ///     - callback:    The callback with the image, run on the main thread.
    func fetchIcon(for size: CGSize, callback: @escaping ((UIImage?) -> Void))
}
