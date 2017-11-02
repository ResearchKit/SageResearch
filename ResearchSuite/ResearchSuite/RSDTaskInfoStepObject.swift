//
//  RSDTaskInfoStepObject.swift
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

/**
 `RSDTaskInfoStepObject` is a concrete implementation of the `RSDTaskInfoStep` protocol.
 */
public struct RSDTaskInfoStepObject : RSDTaskInfoStep, RSDSchemaInfo, Decodable {

    private enum CodingKeys : String, CodingKey {
        
        case identifier
        case type
        case schemaIdentifier
        case schemaRevision
        case title
        case subtitle
        case detail
        case copyright
        case estimatedMinutes
        case icon
        case taskTransformer
    }

    public let identifier: String
    public let type: String
    
    public var title: String?
    public var subtitle: String?
    public var detail: String?
    public var copyright: String?
    public var icon: RSDImageWrapper?
    public var estimatedMinutes: Int = 0
    
    private var _schemaIdentifier: String?
    public var schemaIdentifier: String? {
        return _schemaIdentifier ?? identifier
    }
    public var schemaRevision: Int = 1
    
    public var taskTransformer: RSDTaskTransformer!
    
    public var estimatedFetchTime: TimeInterval {
        return taskTransformer?.estimatedFetchTime ?? 0
    }
    
    public var text: String? {
        return nil
    }
    
    public var footnote: String? {
        return copyright
    }

    public init(with identifier: String) {
        self.identifier = identifier
        self.type = RSDFactory.StepType.taskInfo.rawValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? RSDFactory.StepType.taskInfo.rawValue
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.copyright = try container.decodeIfPresent(String.self, forKey: .copyright)
        self.icon = try container.decodeIfPresent(RSDImageWrapper.self, forKey: .icon)
        self.estimatedMinutes = try container.decodeIfPresent(Int.self, forKey: .estimatedMinutes) ?? 0
        self._schemaIdentifier = try container.decodeIfPresent(String.self, forKey: .schemaIdentifier)
        self.schemaRevision = try container.decodeIfPresent(Int.self, forKey: .schemaRevision) ?? 1

        if container.contains(.taskTransformer) {
            let nestedDecoder = try container.superDecoder(forKey: .taskTransformer)
            self.taskTransformer = try decoder.factory.decodeTaskTransformer(from: nestedDecoder)
        }
    }
    
    public func fetchTask(with factory: RSDFactory, callback: @escaping RSDTaskFetchCompletionHandler) {
        guard let transformer = self.taskTransformer else {
            let message = "Attempting to fetch a task with a nil transformer."
            assertionFailure(message)
            DispatchQueue.main.async {
                callback(self, nil, RSDValidationError.unexpectedNullObject(message))
            }
            return
        }
        transformer.fetchTask(with: factory, taskInfo: self, schemaInfo: self, callback: callback)
    }
    
    public func fetchIcon(for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        RSDImageWrapper.fetchImage(image: icon, for: size, callback: callback)
    }
    
    public func instantiateStepResult() -> RSDResult {
        return RSDTaskResultObject(identifier: identifier)
    }
    
    public func validate() throws {
        // do nothing
    }
    
    public func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        return nil
    }
    
    public func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        return nil
    }
}

extension RSDTaskInfoStepObject : Equatable {
    public static func ==(lhs: RSDTaskInfoStepObject, rhs: RSDTaskInfoStepObject) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.title == rhs.title &&
            lhs.detail == rhs.detail &&
            lhs.copyright == rhs.copyright &&
            lhs.estimatedMinutes == rhs.estimatedMinutes &&
            lhs.icon == rhs.icon
    }
}

extension RSDTaskInfoStepObject : Hashable {
    public var hashValue : Int {
        return self.identifier.hashValue
    }
}

extension RSDTaskInfoStepObject : RSDTaskGroup {
    public var tasks: [RSDTaskInfoStep] {
        return [self]
    }
}
