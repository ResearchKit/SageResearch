//
//  RSDJSONNumber.swift
//  Research
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

/// `RSDJSONNumber` implements converting a Swift number to an Objective-C `NSNumber`.
public protocol RSDJSONNumber : Codable {
    
    /// Return an NSNumber for use in json encoding
    func jsonNumber() -> NSNumber?
}

extension Bool : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return self as NSNumber
    }
}

extension Int : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension Int8 : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension Int16 : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension Int32 : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension Int64 : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension UInt : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension UInt8 : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension UInt16 : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension UInt32 : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension UInt64 : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension Double : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}

extension Float : RSDJSONNumber {
    public func jsonNumber() -> NSNumber? {
        return NSNumber(value: self)
    }
}
