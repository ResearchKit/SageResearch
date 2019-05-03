//
//  CatalogFactory.swift
//  RSDCatalog
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
import Research

/// Stub out a factory for this application. Any factory overrides that are used by the catalog
/// can be declared here. This stub is intentional so that unit tests will all use this rather
/// than risk adding it later and having unit tests fail to match the app logic b/c they do not
/// reference the preferred factory.
class CatalogFactory : RSDFactory {
    
    // TODO: syoung 01/18/2019 Refactor the way factories work to allow registering different factories
    // for different tasks. For now, just shoehorn it in there.
    func decodeTaskGroups(from jsonData: Data) throws -> [RSDTaskGroup] {
        let jsonDecoder = createJSONDecoder()
        let taskGroups = try jsonDecoder.decode(TaskGroupDecoder.self, from: jsonData)
        return taskGroups.taskGroups
    }
}


struct TaskGroupDecoder : Decodable {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case taskGroups
    }
    
    let taskGroups: [RSDTaskGroup]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)        
        var nestedContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .taskGroups)
        var decodedTasks : [RSDTaskGroup] = []
        while !nestedContainer.isAtEnd {
            let taskDecoder = try nestedContainer.superDecoder()
            let task: RSDTaskGroup = try RSDTaskGroupObject(from: taskDecoder)
            decodedTasks.append(task)
        }
        self.taskGroups = decodedTasks
    }
    
}
