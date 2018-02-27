//
//  RSDTrackedItemsReviewStepObject.swift
//  ResearchSuite
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

/// `RSDTrackedItemsReviewStepObject` is intended for use in reviewing a list of selected tracked items and
/// adding details if necessary.
///
/// - seealso: `RSDMedicationTrackingStepNavigator`
open class RSDTrackedItemsReviewStepObject : RSDTrackedSelectionStepObject, RSDTrackedItemsReviewStep {
    
    private enum CodingKeys : String, CodingKey {
        case addDetailsTitle, addDetailsSubtitle, reviewTitle, reviewSubtitle
    }
    
    /// The result with the list of selected items.
    public var result: RSDTrackedItemsResult?
    
    /// The title text to display when the details about each tracked item are not all filled in.
    public var addDetailsTitle: String?
    
    /// The detail text to display when the details about each tracked item are not all filled in.
    public var addDetailsSubtitle: String?
    
    /// The title text to display as the title when all the details have been added.
    public var reviewTitle: String?
    
    /// The detail text to display as the title when all the details have been added.
    public var reviewSubtitle: String?
    
    /// Override the title to return the appropriate string given the current review state.
    open override var title: String? {
        get {
            return super.title ?? (self.hasRequiredValues ? reviewTitle : addDetailsTitle)
        }
        set {
            super.title = newValue
        }
    }
    
    /// Override the `detail` property to return the appropriate string given the current review state.
    open override var detail: String? {
        get {
            return super.detail ?? (self.hasRequiredValues ? reviewSubtitle : addDetailsSubtitle)
        }
        set {
            super.detail = newValue
        }
    }
    
    /// Initializer required for `copy(with:)` implementation.
    public required init(identifier: String, type: RSDStepType?) {
        super.init(identifier: identifier, type: type ?? .review)
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - inputFields: The input fields used to create this step.
    public override init(identifier: String, items: [RSDTrackedItem], sections: [RSDTrackedSection]? = nil, type: RSDStepType? = nil) {
        super.init(identifier: identifier, items: items, sections: sections, type: .review)
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.addDetailsTitle = try container.decodeIfPresent(String.self, forKey: .addDetailsTitle)
        self.addDetailsSubtitle = try container.decodeIfPresent(String.self, forKey: .addDetailsSubtitle)
        self.reviewTitle = try container.decodeIfPresent(String.self, forKey: .reviewTitle)
        self.reviewSubtitle = try container.decodeIfPresent(String.self, forKey: .reviewSubtitle)
        try super.init(from: decoder)
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject, userInfo: [String : Any]?) throws {
        try super.copyInto(copy, userInfo: userInfo)
        guard let subclassCopy = copy as? RSDTrackedItemsReviewStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.addDetailsTitle = userInfo?[CodingKeys.addDetailsTitle.stringValue] as? String ?? self.addDetailsTitle
        subclassCopy.addDetailsSubtitle = userInfo?[CodingKeys.addDetailsSubtitle.stringValue] as? String ?? self.addDetailsSubtitle
        subclassCopy.reviewTitle = userInfo?[CodingKeys.reviewTitle.stringValue] as? String ?? self.reviewTitle
        subclassCopy.reviewSubtitle = userInfo?[CodingKeys.reviewSubtitle.stringValue] as? String ?? self.reviewSubtitle
    }
    
    /// Override the instantiate method and return the current result object.
    override open func instantiateStepResult() -> RSDResult {
        return self.result ?? RSDTrackedItemsResultObject(identifier: self.identifier)
    }
    
    // Overrides must be defined in the base implementation
    
    override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = allCodingKeys()
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.addDetailsTitle, .addDetailsSubtitle, .reviewTitle, .reviewSubtitle]
        return codingKeys
    }
    
    override class func validateAllKeysIncluded() -> Bool {
        guard super.validateAllKeysIncluded() else { return false }
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .addDetailsTitle:
                if idx != 0 { return false }
            case .addDetailsSubtitle:
                if idx != 1 { return false }
            case .reviewTitle:
                if idx != 2 { return false }
            case .reviewSubtitle:
                if idx != 3 { return false }
            }
        }
        return keys.count == 4
    }
    
    override class func examples() -> [[String : RSDJSONValue]] {
        
        let jsonA: [String : RSDJSONValue] = [
            "identifier": "step3",
            "type": "review",
            "addDetailsTitle": "Add details",
            "addDetailsSubtitle": "(Required)",
            "reviewTitle": "Review your selections",
            "reviewSubtitle": "(subtitle)",
            "items" : [["identifier": "selectionA1", "sectionIdentifier": "a"],
                       ["identifier": "selectionA2", "sectionIdentifier": "a"],
                       ["identifier": "selectionB1", "sectionIdentifier": "b"],
                       ["identifier": "selectionB2", "sectionIdentifier": "b"]],
            "sections" : [["identifier" : "a"], ["identifier" : "b"]]
        ]
        
        return [jsonA]
    }
}

/// Simple tracking object for the case where only the identifier is being tracked.
public struct RSDTrackedItemsResultObject : RSDTrackedItemsResult {

    private enum CodingKeys : String, CodingKey {
        case identifier, type, startDate, endDate, identifiers
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
    public private(set) var identifiers: [RSDIdentifier] = []
    
    /// Return the list of identifiers.
    public var selectedAnswers: [RSDTrackedItemAnswer] {
        return self.identifiers
    }
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    /// Create identifier objects from the selected identifiers
    mutating public func updateSelected(to selectedIdentifiers: [String]?,
                                        with items: [RSDTrackedItem],
                                        from taskResult: RSDTaskResult) {
        self.identifiers = selectedIdentifiers?.map { RSDIdentifier(rawValue: $0) } ?? []
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
