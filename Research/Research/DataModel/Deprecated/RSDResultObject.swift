//
//  RSDResultObject.swift
//  Research
//
//  Copyright © 2017-2022 Sage Bionetworks. All rights reserved.
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
import ResultModel

/// `RSDResultObject` is a concrete implementation of the base result associated with a task, step, or asynchronous action.
@available(*,deprecated, message: "Use `JsonModel.ResultObject` instead.")
public struct RSDResultObject : SerializableResultData, RSDNavigationResult, Codable {

    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public let serializableType: SerializableResultType
    
    /// The start date timestamp for the result.
    public var startDate: Date
    
    /// The end date timestamp for the result.
    public var endDate: Date
    
    /// The identifier for the step to go to following this result. If non-nil, then this will be used in
    /// navigation handling.
    public var skipToIdentifier: String?
    
    private enum CodingKeys : String, OrderedEnumCodingKey {
        case serializableType = "type", identifier, startDate, endDate, skipToIdentifier
    }
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    public init(identifier: String, startDate: Date = Date(), endDate: Date = Date(), skipToIdentifier: String? = nil) {
        self.identifier = identifier
        self.serializableType = .base
        self.startDate = startDate
        self.endDate = endDate
        self.skipToIdentifier = skipToIdentifier
    }
    
    public func deepCopy() -> RSDResultObject {
        self
    }
}

