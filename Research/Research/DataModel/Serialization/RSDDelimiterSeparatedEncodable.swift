//
//  RSDCommaSeparatedEncodable.swift
//  Research
//

import Foundation
import JsonModel

/// A special-case encodable that can be encoded to a comma-delimited string.
///
/// A csv-formatted file is a smaller format that might be suitable for saving data to a file that will
/// be parsed into a table, **but** the elements must all conform to single value container encoding
/// **and** they may not include any strings in the encoded value.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDDelimiterSeparatedEncodable : Encodable {
    
    /// An ordered list of coding keys to use when encoding this object to a comma-separated string.
    static func codingKeys() -> [CodingKey]
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDDelimiterSeparatedEncodable {
    
    /// The comma-separated list of header strings to use as the header in a CSV file.
    public static func fileTableHeader(with delimiter: String) -> String {
        return self.codingKeys().map { $0.stringValue }.joined(separator: delimiter)
    }
    
    /// The comma-separated string representing this object.
    public func delimiterEncodedString(with delimiter: String) throws -> String {
        return try rsd_delimiterEncodedString(with: type(of: self).codingKeys(), delimiter: delimiter)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension Encodable {
    
    /// Returns the comma-separated string representing this object.
    /// - parameter codingKeys: The codingKeys to use as mask for the comma-delimited list.
    public func rsd_delimiterEncodedString(with codingKeys: [CodingKey], delimiter: String) throws -> String {
        let dictionary = try self.rsd_jsonEncodedDictionary()
        let values: [String] = try codingKeys.map { (key) -> String in
            guard let value = dictionary[key.stringValue] else { return "" }
            if ((value is [Any]) || (value is [String : Any])) {
                let context = EncodingError.Context(codingPath: [], debugDescription: "A comma-delimited string encoding cannot encode a nested array or dictionary.")
                throw EncodingError.invalidValue(value, context)
            }
            let string = "\(value)"
            if string.contains(delimiter) {
                let context = EncodingError.Context(codingPath: [], debugDescription: "A delimited string encoding cannot encode a string that contains the delimiter: '\(delimiter)'.")
                throw EncodingError.invalidValue(string, context)
            }
            return string
        }
        return values.joined(separator: delimiter)
    }

    /// Encode the object using the factory encoder.
    func rsd_encodeObject(to encoder: FactoryEncoder) throws -> Data {
        let wrapper = _EncodableWrapper(encodable: self)
        return try encoder.encode(wrapper)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version. Use the methods provided by `JsonModel` instead.")
extension Encodable {
    /// Returns JSON-encoded data created by encoding this object using a JSON encoder created
    /// by the shared `RSDFactory` singleton.
    public func rsd_jsonEncodedData() throws -> Data {
        let jsonEncoder = RSDFactory.shared.createJSONEncoder()
        return try self.rsd_encodeObject(to: jsonEncoder)
    }
    
    /// Returns a JSON-encoded dictionary created by encoding this object using a JSON encoder
    /// created by the shared `RSDFactory` singleton.
    public func rsd_jsonEncodedDictionary() throws -> [String : Any] {
        let data = try self.rsd_jsonEncodedData()
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String : Any] else {
            let context = EncodingError.Context(codingPath: [], debugDescription: "Failed to encode the object into a dictionary.")
            throw EncodingError.invalidValue(json, context)
        }
        return dictionary
    }
}

/// The wrapper is required b/c `JSONEncoder` does not implement the `Encoder` protocol.
/// Instead, it uses a private wrapper to box the encoded object.
@available(*,deprecated, message: "Will be deleted in a future version.")
fileprivate struct _EncodableWrapper: Encodable {
    let encodable: Encodable
    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
