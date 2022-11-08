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
