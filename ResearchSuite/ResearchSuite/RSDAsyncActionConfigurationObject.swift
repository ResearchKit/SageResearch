//
//  RSDAsyncActionObject.swift
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

open class RSDAsyncActionObject : RSDAsyncActionConfiguration, Codable {
    
    public private(set) var identifier : String
    public private(set) var startStepIdentifier: String?
    
    public init(identifier : String, startStepIdentifier: String? = nil) {
        self.identifier = identifier
        self.startStepIdentifier = startStepIdentifier
    }
    
    open func validate() throws {
        // Do nothing
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, startStepIdentifier
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.startStepIdentifier = try container.decodeIfPresent(String.self, forKey: .startStepIdentifier)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        if let obj = self.startStepIdentifier { try container.encode(obj, forKey: .startStepIdentifier) }
    }
}

open class RSDRecorderConfigurationObject : RSDAsyncActionObject, RSDRecorderConfiguration {
    
    open var stopStepIdentifier: String?
    
    public init(identifier : String, startStepIdentifier: String? = nil, stopStepIdentifier: String? = nil) {
        self.stopStepIdentifier = stopStepIdentifier
        super.init(identifier: identifier, startStepIdentifier: startStepIdentifier)
    }
    
    private enum CodingKeys : String, CodingKey {
        case stopStepIdentifier
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stopStepIdentifier = try container.decodeIfPresent(String.self, forKey: .stopStepIdentifier)
        
        try super.init(from: decoder)
    }
    
    override open func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let obj = self.stopStepIdentifier { try container.encode(obj, forKey: .stopStepIdentifier) }
    }
}

open class RSDRequestConfigurationObject : RSDAsyncActionObject, RSDRequestConfiguration {
    
    open var waitStepIdentifier: String?
    open var resetTimeInterval: TimeInterval = 0
    open var timeoutTimeInterval: TimeInterval = 2 * 60 // Default is 2 minutes
    
    public init(identifier : String, startStepIdentifier: String? = nil, waitStepIdentifier: String? = nil) {
        self.waitStepIdentifier = waitStepIdentifier
        super.init(identifier: identifier, startStepIdentifier: startStepIdentifier)
    }
    
    private enum CodingKeys : String, CodingKey {
        case waitStepIdentifier, resetTimeInterval, timeoutTimeInterval
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.waitStepIdentifier = try container.decodeIfPresent(String.self, forKey: .waitStepIdentifier)
        if let timeInterval = try container.decodeIfPresent(TimeInterval.self, forKey: .resetTimeInterval) {
            self.resetTimeInterval = timeInterval
        }
        if let timeInterval = try container.decodeIfPresent(TimeInterval.self, forKey: .timeoutTimeInterval) {
            self.timeoutTimeInterval = timeInterval
        }
        
        try super.init(from: decoder)
    }
    
    override open func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let obj = self.waitStepIdentifier { try container.encode(obj, forKey: .waitStepIdentifier) }
        try container.encode(resetTimeInterval, forKey: .resetTimeInterval)
        try container.encode(timeoutTimeInterval, forKey: .timeoutTimeInterval)
    }
}
