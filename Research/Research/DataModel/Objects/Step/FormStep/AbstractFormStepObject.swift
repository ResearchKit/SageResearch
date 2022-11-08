//
//  AbstractFormStepObject.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// This step is included to allow for simplier migration from v2.0 `RSDFormUIStepObject`.
/// To use this step, override the `defaultType()` in your subclass and add your subclass
/// to the `stepSerializer` in your factory init method. Additionally, you will need to
/// add your `ResultNode` implementations to the `resultNodeSerializer`.
///
/// - seealso: `RSDFactory.stepSerializer`, `RSDFactory.resultNodeSerializer`
@available(*,deprecated, message: "Will be deleted in a future version.")
open class AbstractFormStepObject : RSDUIStepObject {
    open override class func defaultType() -> RSDStepType {
        assertionFailure("This is an abstract class. Must override this property in your subclass.")
        return RSDStepType(rawValue: "form")
    }
    
    fileprivate enum CodingKeys : String, CodingKey, CaseIterable {
        case children = "inputFields"
    }
    
    public private(set) var children: [ResultNode]
    
    open func instantiateCollectionResult() -> CollectionResult {
        CollectionResultObject(identifier: self.identifier)
    }
    
    open override func instantiateStepResult() -> ResultData {
        instantiateCollectionResult()
    }
    
    // MARK: Init, Copy, Codable
    
    public required init(identifier: String, children: [ResultNode], nextStepIdentifier: String? = nil) {
        self.children = children
        super.init(identifier: identifier, nextStepIdentifier: nextStepIdentifier)
    }
    
    public required init(identifier: String, type: RSDStepType? = nil) {
        self.children = []
        super.init(identifier: identifier, type: type)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try container.nestedUnkeyedContainer(forKey: .children)
        self.children = try decoder.factory.decodePolymorphicArray(ResultNode.self, from: nestedContainer)
        try super.init(from: decoder)
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = container.nestedUnkeyedContainer(forKey: .children)
        try encoder.factory.encode(self.children, to: nestedContainer)
    }
    
    open override func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? AbstractFormStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.children = self.children.map {
            (($0 as? RSDCopyWithIdentifier)?.copy(with: $0.identifier) as? ResultNode) ?? $0
        }
    }

    // MARK: Documentation
    
    override public class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }

    open override class func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else {
            return super.isRequired(codingKey)
        }
        return key == .children
    }

    open override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .children:
            return .init(propertyType: .interface("\(ResultNode.self)"))
        }
    }

    open override class func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[
            "identifier" : "form",
            "type" : self.defaultType().rawValue,
            "inputFields" : [
                [
                    "identifier": "foo",
                    "type": "simpleQuestion",
                    "title": "What is a good year?",
                    "inputItem": ["type" : "year"]
                ],
                [
                    "identifier": "baroo",
                    "type": "simpleQuestion",
                    "title": "What is a fun word?",
                    "inputItem": ["type" : "string"]
                ]
            ]
        ]]
    }
}
