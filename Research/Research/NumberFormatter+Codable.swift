//
//  RSDNumberFormatter.swift
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

fileprivate enum NumberFormatterCodingKeys: String, CodingKey {
    case maximumFractionDigits = "maximumDigits"
}

extension NumberFormatter {
    
    /// Convenience function for getting the default number formatter with the given `maximumFractionDigits`.
    /// - parameter maximumFractionDigits: The number of decimal places to include.
    /// - returns: A number formatter.
    static func defaultNumberFormatter(with maximumFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.defaultInit()
        return formatter
    }
    
    private func defaultInit() {
        self.generatesDecimalNumbers = true
        self.locale = Locale.current
        self.numberStyle = .decimal
    }
}

extension NumberFormatter { // : Decodable
    
    /// Define an initialier for decoding `NumberFormatter` from a decoder.
    ///
    /// - note: Class extensions cannot conform to the `Decodable` protocol b/c required initializers must be defined
    ///         in the base implementation.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public convenience init(from decoder: Decoder) throws {
        self.init()
        self.defaultInit()
        let container = try decoder.container(keyedBy: NumberFormatterCodingKeys.self)
        if let digits = try container.decodeIfPresent(Int.self, forKey: .maximumFractionDigits) {
            self.maximumFractionDigits = digits
        }
    }
}

extension NumberFormatter : Encodable {
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NumberFormatterCodingKeys.self)
        try container.encode(maximumFractionDigits, forKey: .maximumFractionDigits)
    }
}
