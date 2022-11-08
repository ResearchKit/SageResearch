//
//  RSDNumberFormatter.swift
//  Research
//

import Foundation

@available(*,deprecated, message: "Will be deleted in a future version.")
fileprivate enum NumberFormatterCodingKeys: String, CodingKey {
    case maximumFractionDigits = "maximumDigits"
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension NumberFormatter {
    
    /// Convenience function for getting the default number formatter with the given `maximumFractionDigits`.
    /// - parameter maximumFractionDigits: The number of decimal places to include.
    /// - returns: A number formatter.
    public static func defaultNumberFormatter(with maximumFractionDigits: Int) -> NumberFormatter {
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

@available(*,deprecated, message: "Will be deleted in a future version.")
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

@available(*,deprecated, message: "Will be deleted in a future version.")
extension NumberFormatter : Encodable {
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NumberFormatterCodingKeys.self)
        try container.encode(maximumFractionDigits, forKey: .maximumFractionDigits)
    }
}
