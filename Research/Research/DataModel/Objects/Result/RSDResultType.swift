//
//  RSDResultType.swift
//  Research
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
import JsonModel

/// `RSDResultType` is an extendable string enum used by `RSDFactory` to create the appropriate
/// result type.
public struct RSDResultType : RSDFactoryTypeRepresentable, Codable, Hashable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to creating a `RSDResult`.
    public static let base: RSDResultType = "base"
    
    /// Defaults to creating a `RSDAnswerResult`.
    public static let answer: RSDResultType = "answer"
    
    /// Defaults to creating a `RSDCollectionResult`.
    public static let collection: RSDResultType = "collection"
    
    /// Defaults to creating a `RSDTaskResult`.
    public static let task: RSDResultType = "task"
    
    /// Defaults to creating a `SectionResultObject`.
    public static let section: RSDResultType = "section"
    
    /// Defaults to creating a `RSDFileResult`.
    public static let file: RSDResultType = "file"
    
    /// Defaults to creating a `RSDErrorResult`.
    public static let error: RSDResultType = "error"
    
    /// Defaults to creating a `RSDNavigationResult`.
    public static let navigation: RSDResultType = "navigation"
    
    /// List of all the standard types.
    public static func allStandardTypes() -> [RSDResultType] {
        return [.base, .answer, .collection, .task, .section, .file, .error, .navigation]
    }
}

extension RSDResultType : ExpressibleByStringLiteral {    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDResultType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}

public final class RSDResultSerializer : IdentifiableInterfaceSerializer, PolymorphicSerializer {
    public var documentDescription: String? {
        """
        `Result` is the base implementation for a result associated with a task, step, or
        asynchronous action. When running a task, there will be a result of some variety used to
        mark each step in the task.
        """.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: "\n")
    }
    
    override init() {
        self.examples = [
            RSDTaskResultObject.examples().first!,
            SectionResultObject.examples().first!,
            RSDResultObject.examples().first!,
            AnswerResultObject.examples().first!,
            RSDCollectionResultObject.examples().first!,
            RSDErrorResultObject.examples().first!,
            RSDFileResultObject.examples().first!,
        ]
    }
    
    public private(set) var examples: [RSDResult]
    
    public override class func typeDocumentProperty() -> DocumentProperty {
        .init(propertyType: .reference(RSDResultType.documentableType()))
    }
    
    public func add(_ example: RSDResult) {
        if let idx = examples.firstIndex(where: { $0.typeName == example.typeName }) {
            examples.remove(at: idx)
        }
        examples.append(example)
    }
}
