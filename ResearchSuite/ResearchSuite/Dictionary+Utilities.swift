/*
 Copyright (c) 2017, Sage Bionetworks. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


import Foundation


//public extension Dictionary where Value : Equatable {
//    
//    /**
//     Get the `Key` associated with a given value.
//     
//     @param value   The `Value` to search for.
//     
//     @return        The `Key` if found, else `nil`.
//    */
//    public func key(for value: Value) -> Key? {
//        return self.filter { $1 == value }.map { $0.0 }.first
//    }
//}


//public extension Dictionary {
//
//    /**
//     All the keys in the dictionary.
//    */
//    public var allKeys: [Any]? {
//        return self.map({ (key, _) -> Any in
//            return key
//        })
//    }
//
//    /**
//     Return a `Dictionary` that adds or replaces each entry in this instance with the value from the input `Dictionary`.
//     If both dictionaries have a value for same key, the value of the other dictionary is used.
//
//     @param  merge  The dictionary to add the `<Key, Value>` pairs.
//
//     @return        A `Dictionary` that merges the the dictionaries.
//    */
//    public func merge(from: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
//        var mutableCopy = self
//        for (key, value) in from {
//            mutableCopy[key] = value
//        }
//        return mutableCopy
//    }
//}

