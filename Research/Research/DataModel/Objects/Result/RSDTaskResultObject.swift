//
//  RSDTaskResultObject.swift
//  Research
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
