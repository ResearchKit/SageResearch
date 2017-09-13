//
//  SRSResult.swift
//  SageResearchSDK
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

/**
 A result associated with a task, step, or asyncronous action.
 */
public class SRSResult : NSObject, NSCopying {
    
    /**
     The identifier associated with the task, step, or asyncronous action.
     */
    public private(set) var identifier: String
    
    /**
     The start date timestamp for the result.
     */
    var startDate = Date()
    
    /**
     The end date timestamp for the result.
     */
    var endDate = Date()
    
    public required init(identifier: String) {
        self.identifier = identifier
        super.init()
    }
    
    
    // MARK: NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(identifier: identifier)
        copy.startDate = startDate
        copy.endDate = endDate
        return copy
    }
    
    // MARK: Equality
    
    override public var hash: Int {
        return identifier.hashValue ^ startDate.hashValue ^ endDate.hashValue
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let castObject = object as? SRSResult else { return false }
        return castObject.identifier == self.identifier &&
            castObject.startDate == self.startDate &&
            castObject.endDate == self.endDate
    }
}

/**
 A result associated with a task. This object includes a step history, task run UUID, schema identifier, and asyncronous results.
 */
public class SRSTaskResult : SRSResult {
    
    /**
     A short string that uniquely identifies the associated result schema. If nil, then the `taskIdentifier` is used.
     */
    public var schemaIdentifier: String?
    
    /**
     A revision number associated with the result schema. If `0`, then this is ignored.
     */
    public var schemaRevision: Int = 1
    
    /**
     A unique identifier for this task run.
     */
    public var taskRunUUID = UUID()
    
    /**
     A listing of the step history for this task.
     
     The listed steps can include duplicate identifiers.
     */
    public private(set) var stepHistory: [SRSResult] = []
    
    /**
     A list of all the asyncronous results for this task.
     */
    public private(set) var asyncResults: Set<SRSResult> = []
    
    /**
     Append the step history with a step result. This will only keep the last step result with a unique identifier that will be appended to the end of the step history array.
     */
    public func appendStepHistory(with result: SRSResult) {
        if let previousIndex = stepHistory.index(where: { $0.identifier == result.identifier }) {
            stepHistory.remove(at: previousIndex)
        }
        stepHistory.append(result)
    }
    
    /**
     Insert a result into the asyncronous action results. This will only keep the last result with a unique identifier.
     */
    public func insertAsyncResults(with result: SRSResult) {
        if let previousResult = asyncResults.first(where: { $0.identifier == result.identifier }) {
            asyncResults.remove(previousResult)
        }
        asyncResults.insert(result)
    }
    
    
    // MARK: NSCopying
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SRSTaskResult
        copy.schemaIdentifier = schemaIdentifier
        copy.schemaRevision = schemaRevision
        copy.taskRunUUID = taskRunUUID
        copy.stepHistory = stepHistory
        copy.asyncResults = asyncResults
        return copy
    }
    
    // MARK: Equality
    
    override public var hash: Int {
        return super.hash ^
            SRSObjectHash(schemaIdentifier) ^
            schemaRevision ^
            taskRunUUID.hashValue ^
            stepHistory.reduceHash() ^
            asyncResults.reduceHash()
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let castObject = object as? SRSTaskResult else { return false }
        return SRSObjectEquality(castObject.schemaIdentifier, self.schemaIdentifier) &&
            castObject.schemaRevision == self.schemaRevision &&
            castObject.taskRunUUID == self.taskRunUUID &&
            castObject.stepHistory == self.stepHistory &&
            castObject.asyncResults == self.asyncResults
    }
}
