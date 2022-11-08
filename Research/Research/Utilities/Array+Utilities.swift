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
