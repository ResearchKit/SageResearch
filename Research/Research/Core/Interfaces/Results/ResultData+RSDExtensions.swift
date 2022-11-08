//
//  ResultData+RSDExtensions.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation


extension FileResultObject : RSDArchivable {
    
    /// Build the archiveable or uploadable data for this result.
    public func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)? {
        let filename = self.relativePath
        guard let url = self.url else { return nil }
        let manifest = RSDFileManifest(filename: filename,
                                       timestamp: self.startDate,
                                       contentType: self.contentType,
                                       identifier: self.identifier,
                                       stepPath: stepPath,
                                       jsonSchema: self.jsonSchema)
        let data = try Data(contentsOf: url)
        return (manifest, data)
    }
}

public extension AnswerResult {
    
    var value: Any? {
        return jsonValue?.jsonObject()
    }
}

public extension CollectionResult {
    
    /// Append the result to the end of the input results, replacing the previous instance with the same identifier.
    /// - parameter result: The result to add to the input results.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    func appendInputResults(with result: ResultData) -> ResultData? {
        insert(result)
    }
    
    /// Remove the result with the given identifier.
    /// - parameter result: The result to remove from the input results.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    func removeInputResult(with identifier: String) -> ResultData? {
        remove(with: identifier)
    }
}

extension ResultData {
    
    func shortDescription() -> String {
        if let answerResult = self as? AnswerResult {
            return "{\(self.identifier) : \(String(describing: answerResult.value)))}"
        }
        else if let collectionResult = self as? CollectionResult {
            return "{\(self.identifier) : \(collectionResult.children.map ({ $0.shortDescription() }))}"
        }
        else if let taskResult = self as? RSDTaskResult {
            return "{\(self.identifier) : \(taskResult.stepHistory.map ({ $0.shortDescription() }))}"
        }
        else {
            return self.identifier
        }
    }
}
