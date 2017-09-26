//
//  RSDJSONObject.swift
//  ResearchSuite
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

protocol RSDJSONValue {
    func jsonObject() -> Any
}

extension NSString : RSDJSONValue {
    public func jsonObject() -> Any {
        return self.copy()
    }
}

extension String : RSDJSONValue {
    public func jsonObject() -> Any {
        return self
    }
}

extension NSNumber : RSDJSONValue {
    public func jsonObject() -> Any {
        return self.copy()
    }
}

extension Int : RSDJSONValue {
    public func jsonObject() -> Any {
        return self
    }
}

extension UInt : RSDJSONValue {
    public func jsonObject() -> Any {
        return self
    }
}

extension Bool : RSDJSONValue {
    public func jsonObject() -> Any {
        return self
    }
}

extension Double : RSDJSONValue {
    public func jsonObject() -> Any {
        return self
    }
}

extension Float : RSDJSONValue {
    public func jsonObject() -> Any {
        return self
    }
}

extension NSNull : RSDJSONValue {
    public func jsonObject() -> Any {
        return self
    }
}

extension Date : RSDJSONValue {
    public func jsonObject() -> Any {
        return RSDClassTypeMap.shared.timestampFormatter.string(from: self)
    }
}

extension NSDate : RSDJSONValue {
    public func jsonObject() -> Any {
        return (self as Date).jsonObject()
    }
}

extension DateComponents : RSDJSONValue {
    
    public func jsonObject() -> Any {
        guard let date = self.date ?? Calendar(identifier: .gregorian).date(from: self) else { return NSNull() }
        return defaultFormatter().string(from: date)
    }
    
    public func defaultFormatter() -> DateFormatter {
        if ((year == nil) || (year == 0)) && ((month == nil) || (month == 0)) && ((day == nil) || (day == 0)) {
            return RSDClassTypeMap.shared.timeOnlyFormatter
        }
        else if ((hour == nil) || (hour == 0)) && ((minute == nil) || (minute == 0)) {
            if let year = year, year > 0, let month = month, month > 0, let day = day, day > 0 {
                return RSDClassTypeMap.shared.dateOnlyFormatter
            }
            
            // Build the format string if not all components are included
            var formatString = ""
            if let year = year, year > 0 {
                formatString = "yyyy"
            }
            if let month = month, month > 0 {
                if formatString.characters.count > 0 {
                    formatString.append("-")
                }
                formatString.append("MM")
                if let day = day, day > 0 {
                    if formatString.characters.count > 0 {
                        formatString.append("-")
                    }
                    formatString.append("dd")
                }
            }

            let formatter = DateFormatter()
            formatter.dateFormat = formatString
            return formatter
        }
        return RSDClassTypeMap.shared.timestampFormatter
    }
}

extension NSDateComponents : RSDJSONValue {
    public func jsonObject() -> Any {
        return (self as DateComponents).jsonObject()
    }
}

extension NSUUID : RSDJSONValue {
    public func jsonObject() -> Any {
        return self.uuidString
    }
}

extension UUID : RSDJSONValue {
    public func jsonObject() -> Any {
        return self.uuidString
    }
}

extension NSURL : RSDJSONValue {
    public func jsonObject() -> Any {
        return self.absoluteString ?? NSNull()
    }
}

extension URL : RSDJSONValue {
    public func jsonObject() -> Any {
        return self.absoluteString
    }
}

fileprivate func _convertToJSONValue(from object: Any) -> Any {
    if let obj = object as? RSDJSONValue {
        return obj.jsonObject()
    }
    else if let obj = object as? RSDDictionaryRepresentable {
        let dictionary = obj.dictionaryRepresentation()
        if JSONSerialization.isValidJSONObject(dictionary) {
            return dictionary
        }
        else {
            return dictionary.jsonObject()
        }
    }
    else if let obj = object as? NSObjectProtocol {
        return obj.description
    }
    else {
        return NSNull()
    }
}

extension NSDictionary : RSDJSONValue {
    public func jsonObject() -> Any {
        var dictionary : [AnyHashable : Any] = [:]
        for (key, value) in self.enumerated() {
            dictionary[key] = _convertToJSONValue(from: value)
        }
        return dictionary
    }
}

extension Dictionary : RSDJSONValue {
    public func jsonObject() -> Any {
        return (self as NSDictionary).jsonObject()
    }
}

extension NSArray : RSDJSONValue {
    public func jsonObject() -> Any {
        return self.map { _convertToJSONValue(from: $0) }
    }
}

extension Array : RSDJSONValue {
    public func jsonObject() -> Any {
        return (self as NSArray).jsonObject()
    }
}

extension Set : RSDJSONValue {
    public func jsonObject() -> Any {
        return Array(self).jsonObject()
    }
}

