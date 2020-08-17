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
    
    /// Returns a `Dictionary` containing the results of mapping and filtering `transform`
    /// over `self` where the returned values are a key/value pair.
    ///
    /// Deprecated: Use `reduce(into:)` instead. For example,
    /// ````
    ///    let values = [("a", 234), ("b", 111), ("c", 21), ("d", 52)]
    ///    let mappedDictionary = values.reduce(into: [String : Any]()) { (hashtable, value) in
    ///        guard value.1 % 2 == 0 else { return }
    ///        hashtable[value.0] = value.1
    ///    }
    ///    print(mappedDictionary)
    /// ```
    ///
    /// - parameter transform: The function used to transform the input sequence into a key/value pair
    /// - returns: A dictionary of key/value pairs.
    @available(*, unavailable)
    public func rsd_filteredDictionary<Hashable, T>(_ transform: (Self.Iterator.Element) throws -> (Hashable, T)?) rethrows -> [Hashable: T] {
        fatalError("This method is unavailable. Use `reduce(into:)` instead.")
    }
    
    /// Find the last element in the `Sequence` that matches the given criterion.
    ///
    /// Deprecated: Use `last(where:)` instead.
    ///
    /// - parameter evaluate: The function to use to evaluate the search pattern.
    /// - returns: The element that matches the pattern, searching in reverse.
    @available(*, unavailable)
    public func rsd_last(where evaluate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        fatalError("This method is unavailable. Use `last(where:)` instead.")
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
