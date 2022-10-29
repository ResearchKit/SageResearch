//
//  RSDNavigationResultObject.swift
//  
//
//  Copyright © 2022 Sage Bionetworks. All rights reserved.
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

public final class RSDNavigationResultObject : RSDNavigationResult {

    /// The identifier for the step to go to following this result. If non-nil, then this will be used in
    /// navigation handling. This property is transient and should not be copied or serialized.
    public var skipToIdentifier: String?
    
    public private(set) var wrappedResult: ResultData
    
    public init(wrappedResult: ResultData) {
        self.wrappedResult = wrappedResult
    }
    
    public var typeName: String {
        wrappedResult.typeName
    }
    
    public var identifier: String {
        wrappedResult.identifier
    }
    
    public var startDate: Date {
        get { wrappedResult.startDate }
        set { wrappedResult.startDate = newValue }
    }
    
    public var endDate: Date {
        get { wrappedResult.endDate }
        set { wrappedResult.endDate = newValue }
    }
    
    public func deepCopy() -> RSDNavigationResultObject {
        .init(wrappedResult: wrappedResult.deepCopy())
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedResult.encode(to: encoder)
    }
}
