//
//  RSDTaskResultObject.swift
//  Research
//
//  Copyright © 2017-2022 Sage Bionetworks. All rights reserved.
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
import ResultModel

/// `RSDTaskResultObject` is a result associated with a task. This object includes a step history, task run UUID,
/// schema identifier, and asynchronous results.
public final class RSDTaskResultObject : AbstractAssessmentResultObject, SerializableResultData, AssessmentResult, MultiplatformResultData, RSDTaskResult {
    
    public override class func defaultType() -> SerializableResultType {
        .task
    }
    
    public func deepCopy() -> RSDTaskResultObject {
        var copy = RSDTaskResultObject(identifier: self.identifier,
                                       versionString: self.versionString,
                                       assessmentIdentifier: self.assessmentIdentifier,
                                       schemaIdentifier: self.schemaIdentifier)
        copy.startDate = self.startDate
        copy.endDate = self.endDate
        copy.taskRunUUID = self.taskRunUUID
        copy.stepHistory = self.stepHistory.map { $0.deepCopy() }
        copy.asyncResults = self.asyncResults?.map { $0.deepCopy() }
        copy.nodePath = self.nodePath
        return copy
    }
}

extension RSDTaskResultObject : DocumentableRootObject {
    
    public convenience init() {
        self.init(identifier: "example")
    }
    
    public var jsonSchema: URL {
        URL(string: "\(RSDFactory.shared.modelName(for: self.className)).json", relativeTo: kSageJsonSchemaBaseURL)!
    }
    
    public var documentDescription: String? {
        "A top-level result for this assessment."
    }
}

extension RSDTaskResultObject : DocumentableStruct {

    public static func examples() -> [RSDTaskResultObject] {
        
        var result = RSDTaskResultObject(identifier: "example")
        
        var introStepResult = ResultObject(identifier: "introduction")
        introStepResult.startDate = ISO8601TimestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!
        introStepResult.endDate = introStepResult.startDate.addingTimeInterval(20)
        let collectionResult = CollectionResultObject(identifier: "collection")
        collectionResult.startDateTime = introStepResult.endDate
        collectionResult.endDateTime = collectionResult.startDate.addingTimeInterval(2 * 60)
        var conclusionStepResult = ResultObject(identifier: "conclusion")
        conclusionStepResult.startDate = collectionResult.endDate
        conclusionStepResult.endDate = conclusionStepResult.startDate.addingTimeInterval(20)
        result.stepHistory = [introStepResult, collectionResult, conclusionStepResult]
        
        var fileResult = FileResultObject.examples().first!
        fileResult.startDate = collectionResult.startDate
        fileResult.endDate = collectionResult.endDate
        result.asyncResults = [fileResult]
        
        result.startDate = introStepResult.startDate
        result.endDate = conclusionStepResult.endDate
        
        return [result]
    }
}
