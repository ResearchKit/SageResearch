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

public class RSDTaskObject : RSDUIActionHandlerObject, RSDTask, Decodable {

    public let identifier: String
    public let stepNavigator: RSDStepNavigator
    public let asyncActions: [RSDAsyncActionConfiguration]?
    
    public var taskInfo: RSDTaskInfoStep?
    public var schemaInfo: RSDSchemaInfo?
    
    public init(taskInfo: RSDTaskInfoStep, stepNavigator: RSDStepNavigator, schemaInfo: RSDSchemaInfo? = nil, asyncActions: [RSDAsyncActionConfiguration]? = nil) {
        self.identifier = taskInfo.identifier
        self.taskInfo = taskInfo
        self.schemaInfo = schemaInfo
        self.stepNavigator = stepNavigator
        self.asyncActions = asyncActions
        super.init()
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, taskInfo, schemaInfo, asyncActions, isCancelHidden, isBackHidden
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Set the identifier and
        let identifier: String
        if let taskInfo = try container.decodeIfPresent(RSDTaskInfoStepObject.self, forKey: .taskInfo) {
            identifier = taskInfo.identifier
            self.taskInfo = taskInfo
        }
        else {
            identifier = try container.decode(String.self, forKey: .identifier)
            if let taskInfo = decoder.taskInfo, taskInfo.identifier == identifier {
                self.taskInfo = taskInfo
            }
            else {
                self.taskInfo = decoder.taskDataSource?.taskInfo(with: identifier)
            }
        }
        self.identifier = identifier
        
        // Look for a schema info
        self.schemaInfo = try container.decodeIfPresent(RSDSchemaInfoObject.self, forKey: .schemaInfo) ?? decoder.schemaInfo ?? decoder.taskDataSource?.schemaInfo(with: identifier)
        
        // Get the step navigator
        let factory = decoder.factory
        self.stepNavigator = try factory.decodeStepNavigator(from: decoder)
        
        // Decode the async actions
        if container.contains(.asyncActions) {
            var nestedContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .asyncActions)
            var decodedActions : [RSDAsyncActionConfiguration] = []
            while !nestedContainer.isAtEnd {
                let actionDecoder = try nestedContainer.superDecoder()
                if let action = try factory.decodeAsyncActionConfiguration(from: actionDecoder) {
                    decodedActions.append(action)
                }
            }
            self.asyncActions = decodedActions
        } else {
            self.asyncActions = nil
        }
        
        try super.init(from: decoder)
    }
    
    
    // MARK: RSDTask methods
    
    public func instantiateTaskResult() -> RSDTaskResult {
        return RSDTaskResultObject(identifier: self.identifier, schemaInfo: self.schemaInfo)
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
                throw RSDValidationError.notUniqueIdentifiers("Action identifiers: \(actionIds.joined(separator: ","))")
            }
            // Loop through the async actions and validate them
            for asyncAction in asyncActions! {
                try asyncAction.validate()
                if let startIdentifier = asyncAction.startStepIdentifier {
                    guard stepNavigator.step(with: startIdentifier) != nil else {
                        throw RSDValidationError.identifierNotFound(asyncAction, startIdentifier, "Start step \(startIdentifier) not found for Async Action \(asyncAction.identifier).")
                    }
                }
            }
        }
    }
}
