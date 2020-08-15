//
//  RSDErrorResultObject.swift
//  Research
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
import JsonModel

/// `RSDErrorResult` is a result that holds information about an error.
public struct RSDErrorResultObject : RSDErrorResult, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, type, _startDate = "startDate", _endDate = "endDate", errorDescription, errorDomain, errorCode
    }
    
    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public let type: RSDResultType
    
    /// The start date timestamp for the result.
    public var startDate: Date {
        get { _startDate ?? Date() }
        set { _startDate = newValue }
    }
    private var _startDate: Date?
    
    /// The end date timestamp for the result.
    public var endDate: Date {
        get { _endDate ?? Date() }
        set { _endDate = newValue }
    }
    private var _endDate: Date?
    
    /// A description associated with an `NSError`.
    public let errorDescription: String
    
    /// A domain associated with an `NSError`.
    public let errorDomain: String
    
    /// The error code associated with an `NSError`.
    public let errorCode: Int
    
    /// Initialize using a description, domain, and code.
    /// - parameters:
    ///     - identifier: The identifier for the result.
    ///     - description: The description of the error.
    ///     - domain: The error domain.
    ///     - code: The error code.
    public init(identifier: String, description: String, domain: String, code: Int) {
        self.identifier = identifier
        self.type = .error
        self._startDate = Date()
        self._endDate = Date()
        self.errorDescription = description
        self.errorDomain = domain
        self.errorCode = code
    }
    
    /// Initialize using an error.
    /// - parameters:
    ///     - identifier: The identifier for the result.
    ///     - error: The error for the result.
    public init(identifier: String, error: Error) {
        self.identifier = identifier
        self.type = .error
        self._startDate = Date()
        self._endDate = Date()
        self.errorDescription = (error as NSError).localizedDescription
        self.errorDomain = (error as NSError).domain
        self.errorCode = (error as NSError).code
    }
}

extension RSDErrorResultObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case ._startDate, ._endDate:
            return false
        default:
            return true
        }
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .type:
            return .init(constValue: RSDResultType.error)
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case ._startDate, ._endDate:
            return .init(propertyType: .format(.dateTime))
        case .errorDomain, .errorDescription:
            return .init(propertyType: .primitive(.string))
        case .errorCode:
            return .init(propertyType: .primitive(.integer))
        }
    }
    
    public static func examples() -> [RSDErrorResultObject] {
        return [RSDErrorResultObject(identifier: "errorResult", description: "example error", domain: "ExampleDomain", code: 1)]
    }
}

