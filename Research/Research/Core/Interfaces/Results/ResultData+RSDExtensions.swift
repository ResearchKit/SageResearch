//
//  ResultData+RSDExtensions.swift
//  Research
//
//  Copyright © 2017-2021 Sage Bionetworks. All rights reserved.
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
