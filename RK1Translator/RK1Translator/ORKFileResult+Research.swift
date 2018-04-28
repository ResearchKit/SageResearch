//
//  ORKFileResult+ResearchStack2.swift
//  RK1Translator
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

/// The `ORKFileResult` implements the `RSDFileResult` protocol.
extension ORKFileResult : RSDFileResult {
    
    /// Returns `fileURL`.
    public var url: URL? {
        get {
            return fileURL
        }
        set(newValue) {
            self.fileURL = newValue
        }
    }
    
    /// Returns `fileURL.relativePath`.
    public var relativePath: String? {
        return fileURL?.relativePath
    }
    
    /// Returns `nil`.
    public var startUptime: TimeInterval? {
        return nil
    }
    
    /// Returns `.file`
    public var type: RSDResultType {
        return .file
    }
    
    /// Encodes the result as an `RSDFileResultObject`
    public func encode(to encoder: Encoder) throws {
        var result = RSDFileResultObject(identifier: identifier)
        result.startDate = startDate
        result.endDate = endDate
        result.url = self.fileURL
        try result.encode(to: encoder)
    }
}
