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

extension Sequence {
    
    /// Returns an `Set` containing the results of mapping and filtering `transform`
    /// over `self`.
    /// - parameter transform: The method which returns either the transformed element or `nil` if filtered.
    /// - returns: A set of the transformed elements.
    public func rsd_flatMapSet<T : Hashable>(_ transform: (Self.Iterator.Element) throws -> T?) rethrows -> Set<T> {
        var result = Set<T>()
        for element in self {
            if let t = try transform(element) {
                result.insert(t)
            }
        }
        return result
    }
    
    /// Returns an `Array` containing the results of mapping and filtering `transform`
    /// over `self`.
    ///
    /// Deprecated: Use `flatMap()` instead.
    ///
    /// - parameter transform: The method which returns either the transformed element or `nil` if filtered.
    /// - returns: An array of the transformed elements.
    @available(*, deprecated)
    public func rsd_mapAndFilter<T>(_ transform: (Self.Iterator.Element) throws -> T?) rethrows -> [T] {
        var result = [T]()
        for element in self {
            if let t = try transform(element) {
                result.append(t)
            }
        }
        return result
    }
    
    /// Returns a `Dictionary` containing the results of mapping and filtering `transform`
    /// over `self` where the returned values are a key/value pair.
    /// - parameter transform: The function used to transform the input sequence into a key/value pair
    /// - returns: A dictionary of key/value pairs.
    public func rsd_filteredDictionary<Hashable, T>(_ transform: (Self.Iterator.Element) throws -> (Hashable, T)?) rethrows -> [Hashable: T] {
        var result = [Hashable:T]()
        for element in self {
            if let (key, t) = try transform(element) {
                result[key] = t
            }
        }
        return result
    }
    
    /// Find the last element in the `Sequence` that matches the given criterion.
    /// - parameter evaluate: The function to use to evaluate the search pattern.
    /// - returns: The element that matches the pattern, searching in reverse.
    public func rsd_last(where evaluate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        for element in self.reversed() {
            if try evaluate(element) {
                return element
            }
        }
        return nil
    }
    
    /// Find the next element in the `Sequence` after the element that matches the given criterion.
    /// - parameter evaluate: The function to use to evaluate the search pattern.
    /// - returns: The next element after the one that matchs the pattern.
    public func rsd_next(after evaluate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        var found = false
        for element in self {
            if found {
                return element
            }
            found = try evaluate(element)
        }
        return nil
    }
    
    /// Find the previous element in the `Sequence` before the element that matches the given criterion. Evaluation is
    /// performed on the reversed enumeration.
    /// - parameter evaluate: The function to use to evaluate the search pattern.
    /// - returns: The previous element before the one that matchs the pattern.
    public func rsd_previous(before evaluate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        var found = false
        for element in self.reversed() {
            if found {
                return element
            }
            found = try evaluate(element)
        }
        return nil
    }
}
