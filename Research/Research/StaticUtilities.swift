//
//  StaticUtilities.swift
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

/// Light-weight protocol for handling generic equality without requiring a class or
/// struct to implement all of the `NSObjectProtocol`.
public protocol RSDObjectProtocol {
    
    /// Equality test that does not require knowing the cast of the object being tested.
    /// - parameter object: The object against which to test equality.
    /// - returns: `true` if the objects are equal.
    func isEqual(_ object: Any?) -> Bool
    
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    var hashValue: Int { get }
}

/// Static global function for comparing equality between any two objects.
///
/// This function will return `true` if:
/// 1. Both objects are `nil`
/// 2. The objects both conform to `NSObjectProtocol` and the `isEqual()` function returns `true`.
/// 3. The left-hand object conforms to `RSDObjectProtocol` and the `isEqual()` function returns `true`.
public func RSDObjectEquality(_ objA: Any?, _ objB: Any?) -> Bool {
    if objA == nil && objB == nil {
        return true
    }
    if let objA = objA as? NSObjectProtocol, let objB = objB as? NSObjectProtocol {
        return objA.isEqual(objB)
    }
    if let objA = objA as? RSDObjectProtocol {
        return objA.isEqual(objB)
    }
    return false
}

/// Static global function for getting the hash value for any object.
///
/// 1. If the object conforms to `NSObjectProtocol`, then `hash` will be returned.
/// 2. If the object casts to `AnyHashable`, then the `hashValue` will be returned.
/// 3. If the object conforms to `RSDObjectProtocol`, then the `hashValue` will be returned.
public func RSDObjectHash(_ obj: Any?) -> Int {
    return  (obj as? NSObjectProtocol)?.hash ??
            (obj as? AnyHashable)?.hashValue ??
            0
}
