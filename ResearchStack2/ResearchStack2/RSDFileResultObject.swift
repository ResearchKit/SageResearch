//
//  RSDFileResultObject.swift
//  ResearchStack2
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

/// `RSDFileResultObject` is a concrete implementation of a result that holds a pointer to a file url.
public struct RSDFileResultObject : RSDFileResult, Codable {
    
    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public let type: RSDResultType
    
    /// The start date timestamp for the result.
    public var startDate: Date = Date()
    
    /// The end date timestamp for the result.
    public var endDate: Date = Date()
    
    /// The system clock uptime when the recorder was started (if applicable).
    public var startUptime: TimeInterval?
    
    /// The URL with the full path to the file-based result. This should *not*
    /// be encoded in the file result.
    public var url: URL? {
        get { return _url }
        set {
            _url = newValue
            relativePath = newValue?.relativePath
        }
    }
    private var _url: URL? = nil
    
    /// The relative path to the file-based result.
    public var relativePath: String?
    
    /// The MIME content type of the result.
    public var contentType: String?
    
    private enum CodingKeys : String, CodingKey {
        case identifier, type, startDate, endDate, startUptime, relativePath, contentType
    }
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    ///     - type: The `RSDResultType` for this result. Default = `.file`.
    public init(identifier: String, type: RSDResultType = .file) {
        self.identifier = identifier
        self.type = type
    }
}

extension RSDFileResultObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .type, .startDate, .endDate, .startUptime, .relativePath, .contentType]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .type:
                if idx != 1 { return false }
            case .startDate:
                if idx != 2 { return false }
            case .endDate:
                if idx != 3 { return false }
            case .startUptime:
                if idx != 4 { return false }
            case .relativePath:
                if idx != 5 { return false }
            case .contentType:
                if idx != 6 { return false }
            }
        }
        return keys.count == 7
    }
    
    static func exampleResult() -> RSDFileResultObject {
        var fileResult = RSDFileResultObject(identifier: "fileResult")
        fileResult.startDate = rsd_ISO8601TimestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!
        fileResult.endDate = fileResult.startDate.addingTimeInterval(5 * 60)
        fileResult.startUptime = 1234.567
        fileResult.relativePath = "temp.json"
        return fileResult
    }
    
    static func examples() -> [Encodable] {
        let fileResult = exampleResult()
        return [fileResult]
    }
}
