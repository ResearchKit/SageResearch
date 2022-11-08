//
//  RSDChoiceObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDChoiceObject` is a concrete implementation of `RSDChoice` that can be used to
/// track a multiple choice, single choice, or multiple component input field where each
/// choice in the input field maps to a specific value.
@available(*,deprecated, message: "Will be deleted in a future version.")
public struct RSDChoiceObject<T : Codable> : RSDChoice, RSDComparable, Codable {

    public typealias Value = T
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case value, text, detail, icon, isExclusive, exclusive
    }

    
    /// A JSON encodable object to return as the value when this choice is selected.
    public var answerValue: Codable? {
        return _value
    }
    private let _value: Value?
    
    /// Localized text string to display for the choice.
    public let text: String?
    
    /// Additional detail text.
    public let detail: String?
    
    /// For a multiple choice option, is this choice mutually exclusive? For example, "none of the above".
    public let isExclusive: Bool

    /// Whether or not this choice has an image associated with it that should be returned by the fetch icon method.
    public var hasIcon: Bool {
        return self.imageData != nil
    }
    
    /// The optional `RSDImageData` with the pointer to the image.
    public let imageData: RSDImageData?
    
    /// Expected answer for the rule. In this case, it is the `value` associated with this choice.
    public var matchingAnswer: Any? {
        return _value
    }
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - value: A JSON encodable object to return as the value when this choice is selected.
    ///     - text: Localized text string to display for the choice.
    ///     - iconName: The name of the icon associated with this choice.
    ///     - detail: Additional detail text.
    ///     - isExclusive: For a multiple choice option, is this choice mutually exclusive?
    public init(value: Value?, text: String? = nil, iconName: String? = nil, detail: String? = nil, isExclusive: Bool = false) throws {
        _value = value
        if text == nil, iconName == nil, value != nil, value! is String {
            // If both the text and the icon are nil, then see if the value is a string and if so, set that as the text.
            self.text = "\(value!)"
        }
        else {
            self.text = text
        }
        self.detail = detail
        self.imageData = (iconName != nil) ? RSDResourceImageDataObject(imageName: iconName!) : nil
        self.isExclusive = isExclusive
    }
    
    // MARK: Codable

    /// Initialize from a `Decoder`. This decoding method will first look to see if the decoder contains
    /// a dictionary in which case the coding keys will be decoded from that dictionary. Otherwise, the
    /// decoder will decode a single `String` value and set that value as both the `value` property and
    /// the `text` property.
    ///
    /// - seealso: `RSDChoiceInputFieldObject`
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        
        var value: Value?
        var text: String?
        var detail: String?
        var icon: RSDResourceImageDataObject?
        var isExclusive = false
        
        do {
            // Look to see if the container is a dictionary and parse the keys
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decodeIfPresent(Value.self, forKey: .value)
            text = try container.decodeIfPresent(String.self, forKey: .text)
            detail = try container.decodeIfPresent(String.self, forKey: .detail)
            icon = try container.decodeIfPresent(RSDResourceImageDataObject.self, forKey: .icon)
            if let exclusive = try container.decodeIfPresent(Bool.self, forKey: .isExclusive) {
                print("WARNING!!! The \(CodingKeys.isExclusive) key is deprecated. For consistency, this keyword has been changed to \(CodingKeys.exclusive) and support will be deleted in future versions.")
                isExclusive = exclusive
            }
            else {
                isExclusive = try container.decodeIfPresent(Bool.self, forKey: .exclusive) ?? false
            }
        }
        catch DecodingError.typeMismatch(let type, let context) {
            // If attempting to get a dictionary fails, then look to see if this is a single value
            do {
                let container = try decoder.singleValueContainer()
                value = try container.decode(Value.self)
                text = (value != nil) ? "\(value!)" : Localization.localizedString("BUTTON_SKIP")
            }
            catch {
                // If we did not succeed in creating a single value/text from the decoder,
                // then rethrow the error
                throw DecodingError.typeMismatch(type, context)
            }
        }
        
        _value = value
        self.text = text
        self.detail = detail
        self.imageData = icon
        self.isExclusive = isExclusive
    }
    
    /// Encode the result to the given encoder. This will encode the choice as a dictionary.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(_value, forKey: .value)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(detail, forKey: .detail)
        if let imageData = self.imageData as? RSDResourceImageDataObject {
            try container.encode(imageData, forKey: .icon)
        }
        else {
            try container.encodeIfPresent(self.imageData?.imageIdentifier, forKey: .detail)
        }
        try container.encode(isExclusive, forKey: .exclusive)
    }
}
