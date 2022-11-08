//
//  SectionResultObject.swift
//  Research
//
//

import Foundation
import JsonModel
import ResultModel

@available(*,deprecated, message: "Use `JsonModel.BranchNodeResultObject` instead.")
public final class SectionResultObject : AbstractBranchNodeResultObject, SerializableResultData, BranchNodeResult, MultiplatformResultData, RSDTaskResult {
    
    public override class func defaultType() -> SerializableResultType {
        .section
    }
    
    public func deepCopy() -> SectionResultObject {
        SectionResultObject(identifier: identifier,
                            startDate: startDate,
                            endDate: endDate,
                            stepHistory: stepHistory.map { $0.deepCopy() },
                            asyncResults: asyncResults?.map { $0.deepCopy() },
                            path: path)
    }
}

