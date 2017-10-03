//
//  RSDTaskInfoObject.swift
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
 `RSDTaskInfoObject` is a concrete implementation of the `RSDTaskInfo` protocol.
 */
public struct RSDTaskInfoObject : RSDTaskInfo, RSDResourceTransformer, RSDSchemaInfo, Codable {
    
    private enum CodingKeys : String, CodingKey {
        
        case identifier
        case title
        case detail
        case copyright
        case minutes = "estimatedMinutes"
        case icon
        
        case classType
        case resourceName
        case resourceBundle
        
        case sRevision = "schemaRevision"
        case sIdentifier = "schemaIdentifier"
    }

    // MARK: RSDTaskInfo
    public private(set) var identifier: String
    public var title: String?
    public var detail: String?
    public var copyright: String?
    public var icon: RSDImageWrapper?
    
    private var minutes: Int?
    public var estimatedMinutes: Int {
        return minutes ?? 0
    }
    
    // MARK: RSDResourceTransformer
    public var classType: String?
    public var resourceName: String?
    public var resourceBundle: String?
    
    // MARK: RSDSchemaInfo
    private var sRevision: Int?
    public var schemaRevision: Int {
        return sRevision ?? 1
    }

    private var sIdentifier: String?
    public var schemaIdentifier: String? {
        return sIdentifier ?? self.identifier
    }

    public init(with identifier: String) {
        self.identifier = identifier
    }
    
    public func fetchTask(with factory: RSDFactory, callback: @escaping ((RSDTask?, Error?) -> Void)) {
        DispatchQueue.global().async {
            do {
                let task = try factory.decodeTask(with: self, taskInfo: self, schemaInfo: self)
                DispatchQueue.main.async {
                    callback(task, nil)
                }
            } catch let err {
                DispatchQueue.main.async {
                    callback(nil, err)
                }
            }
        }
    }
    
    public func fetchIcon(for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        RSDImageWrapper.fetchImage(image: icon, for: size, callback: callback)
    }
}

extension RSDTaskInfoObject : RSDTaskGroup {
    public var tasks: [RSDTaskInfo] {
        return [self]
    }
}

extension RSDTaskInfoObject : Equatable {
    public static func ==(lhs: RSDTaskInfoObject, rhs: RSDTaskInfoObject) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.title == rhs.title &&
            lhs.detail == rhs.detail &&
            lhs.copyright == rhs.copyright &&
            lhs.estimatedMinutes == rhs.estimatedMinutes &&
            lhs.icon == rhs.icon
    }
}

extension RSDTaskInfoObject : Hashable {
    public var hashValue : Int {
        return self.identifier.hashValue
    }
}
