//
//  RSDResultType.swift
//  Research
//
import Foundation
import JsonModel
import ResultModel


/// `RSDResultType` is an extendable string enum used by `RSDFactory` to create the appropriate
/// result type.
extension SerializableResultType {

    /// Defaults to creating a `RSDTaskResult`.
    public static let task: SerializableResultType = "task"
    
    // syoung 03/09/2022 Added back in for MobileToolbox
    public static let navigation: SerializableResultType = "navigation"
    
    // syoung 05/13/2022 Add in the static value extensions
    public static let answer: SerializableResultType = SerializableResultType.StandardTypes.answer.resultType
    public static let base: SerializableResultType = SerializableResultType.StandardTypes.base.resultType
    public static let collection: SerializableResultType = SerializableResultType.StandardTypes.collection.resultType
    public static let file: SerializableResultType = SerializableResultType.StandardTypes.file.resultType
    public static let error: SerializableResultType = SerializableResultType.StandardTypes.error.resultType
    public static let section: SerializableResultType = SerializableResultType.StandardTypes.section.resultType
}

// List of the serialization examples included in this library.

extension ResultDataSerializer {
    func libraryExamples() -> [SerializableResultData] {
        [
            RSDTaskResultObject.examples().first!,
            SectionResultObject(identifier: "example"),
            RSDResultObject(identifier: "example"),
            RSDCollectionResultObject(identifier: "example"),
        ]
    }
    
    func registerLibraryExamples(with factory: RSDFactory) {
        self.add(contentsOf: libraryExamples())
        factory.registerSerializer(self, for: ResultData.self)
    }
}

