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

public protocol RSDArrayExtension {
}

extension Array : RSDArrayExtension {
    
    /// Remove the elements that evaluate to true and return that array.
    ///
    /// - note: At the time when this function was implemented, the function `removeAll(where:)` had not been
    /// added to Swift. That said, the `removeAll(where:)` function follows the `removeAll()` pattern of
    /// *not* returning the elements that were removed unlike the `remove(at:)` function which has a
    /// discardable result of the removed element. Because this function is used within this library to remove
    /// elements conditionally *and* return the elements that were filtered out, this function will be kept
    /// in the framework. syoung 04/23/2019
    ///
    /// - parameter evaluate: The function to use to evaluate the search pattern.
    /// - returns: The elements that match the pattern.
    @discardableResult
    public mutating func remove(where evaluate: (Element) throws -> Bool) rethrows -> [Element] {
        var indices = Array<Index>()
        var result = Array<Element>()
        for (ii, element) in self.enumerated() {
            if try evaluate(element) {
                indices.append(ii)
                result.append(element)
            }
        }
        for ii in indices.reversed() {
            self.remove(at: ii)
        }
        return result
    }
}
