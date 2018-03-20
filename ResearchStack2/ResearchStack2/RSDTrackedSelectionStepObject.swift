//
//  RSDTrackedSelectionStepObject.swift
//  ResearchStack2
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

/// `RSDTrackedSelectionStepObject` is intended for use in selecting items from a long, sectioned list.
/// In general, this would be the first step in setting up tracked data such as symptoms of a disease
/// or triggers associated with a medical condition.
///
/// - seealso: `RSDTrackedItemsStepNavigator`
open class RSDTrackedSelectionStepObject : RSDUIStepObject, RSDTrackedItemsStep {
    
    private enum CodingKeys: String, CodingKey {
        case items, sections
    }
    
    /// The shared result for review, details, and selection.
    public var result: RSDTrackedItemsResult?
    
    /// The list of the items to track.
    public var items: [RSDTrackedItem]
    
    /// The section items for mapping each medication.
    public var sections: [RSDTrackedSection]?
    
    /// Initializer required for `copy(with:)` implementation.
    public required init(identifier: String, type: RSDStepType?) {
        self.items = []
        super.init(identifier: identifier, type: type ?? .selection)
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject, userInfo: [String : Any]?) throws {
        try super.copyInto(copy, userInfo: userInfo)
        guard let subclassCopy = copy as? RSDTrackedSelectionStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.items = self.items
        subclassCopy.sections = self.sections
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - inputFields: The input fields used to create this step.
    public init(identifier: String, items: [RSDTrackedItem], sections: [RSDTrackedSection]? = nil, type: RSDStepType? = nil) {
        self.items = items
        self.sections = sections
        super.init(identifier: identifier, type: type ?? .selection)
    }

    /// Initialize from a `Decoder`.
    ///
    /// - example:
    /// ```
    ///    let json = """
    ///        {
    ///            "identifier": "foo",
    ///            "type": "selection",
    ///            "title": "Please select the items you wish to track",
    ///            "detail": "Select all that apply",
    ///            "actions": { "goForward": { "buttonTitle" : "Go, Dogs! Go!" },
    ///                         "cancel": { "iconName" : "closeX" },
    ///                        },
    ///            "shouldHideActions": ["goBackward", "skip"],
    ///            "items" : [ {"identifier" : "itemA1", "sectionIdentifier" : "a"},
    ///                        {"identifier" : "itemA2", "sectionIdentifier" : "a"},
    ///                        {"identifier" : "itemA3", "sectionIdentifier" : "a"},
    ///                        {"identifier" : "itemB1", "sectionIdentifier" : "b"},
    ///                        {"identifier" : "itemB2", "sectionIdentifier" : "b"},
    ///                        {"identifier" : "itemB3", "sectionIdentifier" : "b"}],
    ///            "sections" : [ {"identifier" : "a"}, {"identifier" : "b"}]
    ///        }
    ///        """.data(using: .utf8)! // our data in native (JSON) format
    /// ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        // Decode the items and sections
        self.items = try type(of: self).decodeItems(from: decoder) ?? []
        self.sections = try type(of: self).decodeSections(from: decoder)
        try super.init(from: decoder)
    }
    
    /// Overridable class method for decoding tracking items.
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - returns: The decoded items.
    /// - throws: `DecodingError`
    open class func decodeItems(from decoder: Decoder) throws -> [RSDTrackedItem]? {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let items = try container.decodeIfPresent([RSDTrackedItemObject].self, forKey: .items)
        return items
    }
    
    /// Overridable class method for decoding tracking sections.
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - returns: The decoded sections.
    /// - throws: `DecodingError`
    open class func decodeSections(from decoder: Decoder) throws -> [RSDTrackedSection]? {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sections = try container.decodeIfPresent([RSDTrackedSectionObject].self, forKey: .sections)
        return sections
    }
    
    /// Instantiate a step result that is appropriate for this step. The default for this class is a
    /// `RSDTrackedItemsResultObject`. If the `result` property is set, then this will instantiate a
    /// copy of the result with this step's identifier.
    ///
    /// - returns: A result for this step.
    open override func instantiateStepResult() -> RSDResult {
        guard let result = self.result else {
            return RSDTrackedItemsResultObject(identifier: self.identifier)
        }
        return result.copy(with: self.identifier)
    }
    
    /// Validate the step to check for any configuration that should throw an error. This class will
    /// check that the input fields have unique identifiers and will call the `validate()` method on each
    /// input field.
    ///
    /// - throws: An error if validation fails.
    open override func validate() throws {
        try super.validate()
        
        // Check if the identifiers are unique
        let itemsIds = items.map({ $0.identifier })
        let uniqueIds = Set(itemsIds)
        if itemsIds.count != uniqueIds.count {
            throw RSDValidationError.notUniqueIdentifiers("Item identifiers: \(itemsIds.joined(separator: ","))")
        }
        
        // Check if the identifiers are unique
        if let sectionIds = sections?.map({ $0.identifier }) {
            let uniqueIds = Set(sectionIds)
            if sectionIds.count != uniqueIds.count {
                throw RSDValidationError.notUniqueIdentifiers("Item identifiers: \(sectionIds.joined(separator: ","))")
            }
        }
    }
    
    /// Override the default selector to return a tracked selection data source.
    open override func instantiateDataSource(with taskPath: RSDTaskPath, for supportedHints: Set<RSDFormUIHint>) -> RSDTableDataSource? {
        guard supportedHints.contains(.list) else { return nil }
        return RSDTrackedSelectionDataSource(step: self, taskPath: taskPath)
    }
    
    // Overrides must be defined in the base implementation
    
    override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = allCodingKeys()
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.items, .sections]
        return codingKeys
    }
    
    override class func validateAllKeysIncluded() -> Bool {
        guard super.validateAllKeysIncluded() else { return false }
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .items:
                if idx != 0 { return false }
            case .sections:
                if idx != 1 { return false }
            }
        }
        return keys.count == 2
    }
    
    override class func examples() -> [[String : RSDJSONValue]] {
        
        let jsonA: [String : RSDJSONValue] = [
            "identifier": "step3",
            "type": "selection",
            "title": "Make your choices",
            "detail": "Addtional Details",
            "items" : [["identifier": "selectionA1", "sectionIdentifier": "a"],
                       ["identifier": "selectionA2", "sectionIdentifier": "a"],
                       ["identifier": "selectionB1", "sectionIdentifier": "b"],
                       ["identifier": "selectionB2", "sectionIdentifier": "b"]],
            "sections" : [["identifier" : "a"], ["identifier" : "b"]]
        ]
        
        return [jsonA]
    }
}

/// A section header for tracked data.
///
/// - example:
/// ```
///    let json = """
///            {
///                "identifier": "foo",
///                "text": "Text",
///                "detail" : "Detail"
///            }
///            """.data(using: .utf8)! // our data in native (JSON) format
/// ```
public struct RSDTrackedSectionObject : Codable, RSDTrackedSection {
    
    private enum CodingKeys : String, CodingKey {
        case identifier, text, detail
    }
    
    /// A unique identifier for this section.
    public let identifier: String
    
    /// Localized text for the section.
    public let text: String?
    
    /// Localized detail for the section.
    public let detail: String?
    
    public init( identifier: String, text: String? = nil, detail: String? = nil) {
        self.identifier = identifier
        self.text = text
        self.detail = detail
    }
}

/// A generic instance of an item to include in a tracked selection step.
///
/// - example:
/// ```
///    let json = """
///            {
///                "identifier": "advil",
///                "sectionIdentifier": "pain",
///                "title": "Advil",
///                "shortText": "Ibu",
///                "detail": "(Ibuprofen)",
///                "isExclusive": true,
///                "icon": "pill",
///            }
///            """.data(using: .utf8)! // our data in native (JSON) format
/// ```
public struct RSDTrackedItemObject : Codable, RSDTrackedItem, RSDEmbeddedIconVendor {
    
    private enum CodingKeys : String, CodingKey {
        case identifier
        case sectionIdentifier
        case addDetailsIdentifier
        case title
        case shortText
        case detail
        case _isExclusive = "isExclusive"
        case icon
    }
    
    /// A unique identifier that can be used to track the item.
    public let identifier : String
    
    /// An optional identifier that can be used to group the tracked items by section.
    public let sectionIdentifier : String?
    
    /// An optional identifier that can be used to map a tracked item to a mutable step that can be used
    /// to input additional details about the tracked item.
    public let addDetailsIdentifier: String?
    
    /// Localized text to display as the full descriptor.
    public let title : String?
    
    /// Additional detail text.
    public let detail: String?
    
    /// Localized shortened text to display when used in a sentence.
    public let shortText : String?
    
    /// Optional icon to display for the selection.
    public let icon: RSDImageWrapper?
    
    /// Whether or not the tracked item is set up so that *only* this item can be selected
    /// for a given section.
    public var isExclusive: Bool {
        return _isExclusive ?? false
    }
    private let _isExclusive: Bool?
    
    public init(identifier: String, sectionIdentifier: String?, title: String? = nil, shortText: String? = nil, detail: String? = nil, icon: RSDImageWrapper? = nil, isExclusive: Bool = false, addDetailsIdentifier: String? = nil) {
        self.identifier = identifier
        self.sectionIdentifier = sectionIdentifier
        self.title = title
        self.shortText = shortText
        self.detail = detail
        self.icon = icon
        self._isExclusive = isExclusive
        self.addDetailsIdentifier = addDetailsIdentifier
    }
}


/// Simple tracking object for the case where only the identifier is being tracked.
public struct RSDTrackedItemsResultObject : RSDTrackedItemsResult, Codable {

    private enum CodingKeys : String, CodingKey {
        case identifier, type, startDate, endDate, items
    }
    
    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public private(set) var type: RSDResultType = "trackedItemsReview"
    
    /// The start date timestamp for the result.
    public var startDate: Date = Date()
    
    /// The end date timestamp for the result.
    public var endDate: Date = Date()
    
    /// The list of medications that are currently selected.
    public var items: [RSDIdentifier] = []
    
    /// Return the list of identifiers.
    public var selectedAnswers: [RSDTrackedItemAnswer] {
        return self.items
    }
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    public func copy(with identifier: String) -> RSDTrackedItemsResultObject {
        var copy = RSDTrackedItemsResultObject(identifier: identifier)
        copy.items = self.items
        return copy
    }
    
    mutating public func updateSelected(to selectedIdentifiers: [String]?, with items: [RSDTrackedItem]) {
        self.items = selectedIdentifiers?.map { RSDIdentifier(rawValue: $0) } ?? []
    }
    
    mutating public func updateDetails(to newValue: RSDTrackedItemAnswer) {
        // Do nothing
    }
}

extension RSDIdentifier : RSDTrackedItemAnswer {
    
    public var identifier: String {
        return self.stringValue
    }
    
    public var hasRequiredValues: Bool {
        return true
    }
}

extension RSDIdentifier : RSDTrackedItem {
    
    public var sectionIdentifier: String? {
        return nil
    }
    
    public var addDetailsIdentifier: String? {
        return nil
    }
    
    public var title: String? {
        return nil
    }
    
    public var detail: String? {
        return nil
    }
    
    public var shortText: String? {
        return nil
    }
    
    public var isExclusive: Bool {
        return false
    }
    
    public var imageVendor: RSDImageVendor? {
        return nil
    }
}

// Documentable

extension RSDTrackedSectionObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .text, .detail]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .text:
                if idx != 1 { return false }
            case .detail:
                if idx != 2 { return false }
            }
        }
        return keys.count == 3
    }
    
    static func _examples() -> [RSDTrackedSectionObject] {
        let exampleA = RSDTrackedSectionObject(identifier: "foo", text: "Foo Items", detail: "Foo details")
        return [exampleA]
    }
    
    static func examples() -> [Encodable] {
        return _examples()
    }
}

extension RSDTrackedItemObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .sectionIdentifier, .title, .shortText, .detail, ._isExclusive, .icon, .addDetailsIdentifier]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .sectionIdentifier:
                if idx != 1 { return false }
            case .title:
                if idx != 2 { return false }
            case .shortText:
                if idx != 3 { return false }
            case .detail:
                if idx != 4 { return false }
            case ._isExclusive:
                if idx != 5 { return false }
            case .icon:
                if idx != 6 { return false }
            case .addDetailsIdentifier:
                if idx != 7 { return false }
            }
        }
        return keys.count == 8
    }
    
    static func _examples() -> [RSDTrackedItemObject] {
        let exampleA = RSDTrackedItemObject(identifier: "foo", sectionIdentifier: "pain", title: "Foo Brand Pain Killer", shortText: "Foo", detail: "Ease your pain with foo", icon: "fooIcon", isExclusive: true)
        return [exampleA]
    }
    
    static func examples() -> [Encodable] {
        return _examples()
    }
}

extension RSDTrackedItemsResultObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .type, .startDate, .endDate, .items]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .type:
                if idx != 1 { return false }
            case .startDate:
                if idx != 2 { return false }
            case .endDate:
                if idx != 3 { return false }
            case .items:
                if idx != 4 { return false }
            }
        }
        return keys.count == 5
    }
    
    static func _examples() -> [RSDTrackedItemsResultObject] {
        var exampleA = RSDTrackedItemsResultObject(identifier: "foo")
        exampleA.items = [RSDIdentifier(rawValue: "a"), RSDIdentifier(rawValue: "b")]
        return [exampleA]
    }
    
    static func examples() -> [Encodable] {
        return _examples()
    }
}
