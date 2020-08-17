//
//  RSDDataStorageManager.swift
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


/// The data storage manager controls storing of user data that is stored across task runs. It is a
/// composite protocol of the methods defined using Swift, which are required but can include Swift objects
/// and methods that conform to Objective-C protocols which allows for optional implementation of the
/// included methods.
public protocol RSDDataStorageManager : RSDSwiftDataStorageManager, RSDObjCDataStorageManager {
}

public protocol RSDSwiftDataStorageManager : class, NSObjectProtocol {
    
    /// Returns data associated with the previous task run for a given task identifier.
    func previousTaskData(for taskIdentifier: RSDIdentifier) -> RSDTaskData?
    
    /// Store the given task run data.
    /// - parameters:
    ///     - data: The task data object to store.
    ///     - taskResult: The task result (if any) used to create the task data.
    func saveTaskData(_ data: RSDTaskData, from taskResult: RSDTaskResult?)
}

@objc public protocol RSDObjCDataStorageManager : class, NSObjectProtocol {
    
    /// Optional. Should survey questions be shown in subsequent runs using the results from a
    /// previous run?
    @objc optional func shouldUsePreviousAnswers(for taskIdentifier: String) -> Bool
}
