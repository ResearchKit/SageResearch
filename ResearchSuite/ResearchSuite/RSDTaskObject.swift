//
//  RSDTaskObject.swift
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

public struct RSDTaskObject : RSDTask, Decodable {
    
    public private(set) var identifier: String
    public private(set) var stepNavigator: RSDStepNavigator
    public private(set) var asyncActions: [RSDAsyncAction]?
    
    public var taskInfo: RSDTaskInfo?
    public var schemaInfo: RSDSchemaInfo?
    
    public init(taskInfo: RSDTaskInfo, stepNavigator: RSDStepNavigator, schemaInfo: RSDSchemaInfo? = nil, asyncActions: [RSDAsyncAction]? = nil) {
        self.identifier = taskInfo.identifier
        self.taskInfo = taskInfo
        self.schemaInfo = schemaInfo
        self.stepNavigator = stepNavigator
        self.asyncActions = asyncActions
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, taskInfo, schemaInfo
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.taskInfo = try container.decodeIfPresent(RSDTaskInfoObject.self, forKey: .taskInfo)
        self.schemaInfo = try container.decodeIfPresent(RSDSchemaInfoObject.self, forKey: .schemaInfo)
        
        let factory = decoder.userInfo[RSDFactory.decoderFactoryKey] as? RSDFactory ?? RSDFactory.shared
        self.stepNavigator = try factory.decodeStepNavigator(decoder: decoder)
    }
    
    public func validate() throws {
        // Check if the step navigator implements step validation
        if let stepValidator = stepNavigator as? RSDStepValidator {
            try stepValidator.stepValidation()
        }
        
        // Check if the async action identifiers are unique
        if let actionIds = asyncActions?.map({ $0.identifier }) {
            let uniqueIds = Set(actionIds)
            if actionIds.count != uniqueIds.count {
                throw RSDValidationError.notUniqueIdentifiers
            }
        }
    }
}
