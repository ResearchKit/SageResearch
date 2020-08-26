//
//  QuestionsObjects.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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
import JsonModel

// TODO: syoung 04/06/2020 Implement ComboBoxQuestionObject supported in Kotlin frameworks

open class AbstractQuestionStep : RSDUIStepObject, SurveyRuleNavigation, RSDCohortAssignmentStep {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case surveyRules, isOptional = "optional"
    }
    
    public var surveyRules: [RSDSurveyRule] = []
    open var isOptional: Bool {
        get { _isOptional ?? true }
        set { _isOptional = newValue }
    }
    private var _isOptional: Bool?

    /// Identifier to skip to if all input fields have nil answers.
    open var skipToIfNil: String? {
        guard let skipAction = self.action(for: .navigation(.skip), on: self) as? RSDNavigationUIAction
            else {
                return nil
        }
        return skipAction.skipToIdentifier
    }
    
    open override func nextStepIdentifier(with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        evaluateSurveyRules(with: result, isPeeking: isPeeking) ??
            super.nextStepIdentifier(with: result, isPeeking: isPeeking)
    }
    
    open func cohortsToApply(with result: RSDTaskResult) -> (add: Set<String>, remove: Set<String>)? {
        evaluateCohortsToApply(with: result)
    }
    
    open override func instantiateDataSource(with parent: RSDPathComponent?, for supportedHints: Set<RSDFormUIHint>) -> RSDTableDataSource? {
        guard let questionStep = self as? QuestionStep else {
            debugPrint("WARNING!!! \(self) does not implement the `QuestionStep` protocol")
            return super.instantiateDataSource(with: parent, for: supportedHints)
        }
        return QuestionStepDataSource(step: questionStep, parent: parent, supportedHints: supportedHints)
    }
    
    /// Instantiate a step result that is appropriate for this step.
    /// - returns: A result for this step.
    open override func instantiateStepResult() -> RSDResult {
        guard let question = self as? QuestionStep else {
            return RSDResultObject(identifier: self.identifier)
        }
        return AnswerResultObject(identifier: self.identifier,
                                  answerType: question.answerType,
                                  value: nil,
                                  questionText: self.title ?? self.subtitle ?? self.detail)
    }
    
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._isOptional = try container.decodeIfPresent(Bool.self, forKey: .isOptional) ?? self._isOptional
        // Decode the survey rules. Kotlin serialization does not allow for using a polymophic
        // decoding without a "type" key on each element, so this is a work-around.
        if container.contains(.surveyRules) {
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .surveyRules)
            var surveyRules = [RSDSurveyRule]()
            while !nestedContainer.isAtEnd {
                let nestedDecoder = try nestedContainer.superDecoder()
                let surveyRule = try self.decodeSurveyRule(from: nestedDecoder)
                surveyRules.append(surveyRule)
            }
            self.surveyRules = surveyRules
        }
    }
    
    open func decodeSurveyRule(from decoder: Decoder) throws -> RSDSurveyRule {
        try JsonSurveyRuleObject(from: decoder)
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? AbstractQuestionStep else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.surveyRules = self.surveyRules
        subclassCopy._isOptional = self._isOptional
    }
    
    override open func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self._isOptional, forKey: .isOptional)
        if self.surveyRules.count > 0 {
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .surveyRules)
            guard let encodables = self.surveyRules as? [Encodable] else {
                throw EncodingError.invalidValue(self.surveyRules, EncodingError.Context(codingPath: nestedContainer.codingPath, debugDescription: "The surveyRules do not conform to the Encodable protocol"))
            }
            for encodable in encodables {
                let nestedEncoder = nestedContainer.superEncoder()
                try encodable.encode(to: nestedEncoder)
            }
        }
    }
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override public class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .surveyRules:
            return .init(propertyType: .referenceArray(JsonSurveyRuleObject.documentableType()))
        case .isOptional:
            return .init(propertyType: .primitive(.boolean))
        }
    }
}

open class AbstractSkipQuestionStep : AbstractQuestionStep {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case skipCheckbox
    }
    
    public fileprivate(set) var skipCheckbox: SkipCheckboxInputItem? = nil
    
    public override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.skipCheckbox = try container.decodeIfPresent(SkipCheckboxInputItemObject.self, forKey: .skipCheckbox)
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? AbstractSkipQuestionStep else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.skipCheckbox = self.skipCheckbox
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let obj = self.skipCheckbox {
            let nestedEncoder = container.superEncoder(forKey: .skipCheckbox)
            if let encodable = obj as? Encodable {
                try encodable.encode(to: nestedEncoder)
            }
            else {
                throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: nestedEncoder.codingPath, debugDescription: "The skipCheckbox does not conform to the Encodable protocol"))
            }
        }
    }
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override public class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .skipCheckbox:
            return .init(propertyType: .reference(SkipCheckboxInputItemObject.documentableType()))
        }
    }
}

public final class SimpleQuestionStepObject : AbstractSkipQuestionStep, SimpleQuestion, QuestionStep, Encodable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case inputItem
    }
    
    public private(set) var inputItem: InputItemBuilder = StringTextInputItemObject()

    public override class func defaultType() -> RSDStepType {
        .simpleQuestion
    }
    
    public init(identifier: String,
                inputItem: InputItemBuilder = StringTextInputItemObject(),
                nextStepIdentifier: String? = nil,
                skipCheckbox: SkipCheckboxInputItem? = nil) {
        self.inputItem = inputItem
        super.init(identifier: identifier,
                   nextStepIdentifier: nextStepIdentifier)
        self.skipCheckbox = skipCheckbox
    }
    
    /// Initializer required for `Decodable` protocol.
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    /// Initializer required for `copy(with:)` implementation.
    public required init(identifier: String, type: RSDStepType?) {
        super.init(identifier: identifier, type: type)
    }
    
    public override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let factory = decoder.factory
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.inputItem) {
            let nestedDecoder = try container.superDecoder(forKey: .inputItem)
            self.inputItem = try factory.decodePolymorphicObject(InputItemBuilder.self, from: nestedDecoder)
        }
    }
    
    /// Override to set the properties of the subclass.
    override public func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? SimpleQuestionStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.inputItem = self.inputItem
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        let inputItemEncoder = container.superEncoder(forKey: .inputItem)
        if let encodable = self.inputItem as? Encodable {
            try encodable.encode(to: inputItemEncoder)
        }
        else {
            throw EncodingError.invalidValue(self.inputItem, EncodingError.Context(codingPath: inputItemEncoder.codingPath, debugDescription: "The surveyRules do not conform to the Encodable protocol"))
        }
    }
    
    override public class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    public override class func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else {
            return super.isRequired(codingKey)
        }
        return key == .inputItem
    }
    
    override public class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .inputItem:
            return .init(propertyType: .interface("\(InputItemBuilder.self)"))
        }
    }
    
    override public class func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "optional": false,
            "inputItem": ["type" : "year"],
            "skipCheckbox": ["type":"skipCheckbox","fieldLabel":"No answer"],
            "surveyRules": [[ "matchingAnswer": 1900 ]]
        ]]
    }
}

public final class MultipleInputQuestionStepObject : AbstractSkipQuestionStep, MultipleInputQuestion, QuestionStep, Encodable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case inputItems, sequenceSeparator
    }
    
    public private(set) var inputItems: [InputItemBuilder]
    public private(set) var sequenceSeparator: String?
    
    public override class func defaultType() -> RSDStepType {
        .multipleInputQuestion
    }
    
    public init(identifier: String,
                inputItems: [InputItemBuilder],
                nextStepIdentifier: String? = nil,
                skipCheckbox: SkipCheckboxInputItem? = nil,
                sequenceSeparator: String? = nil) {
        self.inputItems = inputItems
        self.sequenceSeparator = sequenceSeparator
        super.init(identifier: identifier, nextStepIdentifier: nextStepIdentifier)
        self.skipCheckbox = skipCheckbox
    }
    
    /// Initializer required for `Decodable` protocol.
    public required init(from decoder: Decoder) throws {
        let factory = decoder.factory
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try container.nestedUnkeyedContainer(forKey: .inputItems)
        self.inputItems = try factory.decodePolymorphicArray(InputItemBuilder.self, from: nestedContainer)
        self.sequenceSeparator = try container.decodeIfPresent(String.self, forKey: .sequenceSeparator)
        try super.init(from: decoder)
    }
    
    /// Initializer required for `copy(with:)` implementation.
    public required init(identifier: String, type: RSDStepType?) {
        self.inputItems = []
        self.sequenceSeparator = nil
        super.init(identifier: identifier, type: type)
    }
    
    public override func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? MultipleInputQuestionStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.inputItems = self.inputItems
        subclassCopy.sequenceSeparator = self.sequenceSeparator
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.sequenceSeparator, forKey: .sequenceSeparator)
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .inputItems)
        if let encodables = self.inputItems as? [Encodable] {
            try encodables.forEach {
                let nestedEncoder = nestedContainer.superEncoder()
                try $0.encode(to: nestedEncoder)
            }
        }
        else {
            throw EncodingError.invalidValue(self.inputItems, EncodingError.Context(codingPath: nestedContainer.codingPath, debugDescription: "The inputItems do not conform to the Encodable protocol"))
        }
    }
    
    override public class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    public override class func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else {
            return super.isRequired(codingKey)
        }
        return key == .inputItems
    }
    
    override public class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .inputItems:
            return .init(propertyType: .interfaceArray("\(InputItemBuilder.self)"))
        case .sequenceSeparator:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    override public class func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "optional": false,
            "inputItems":[["type" : "year", "identifier": "year"],
                          ["type": "string", "identifier": "name"]],
            "skipCheckbox":["type":"skipCheckbox","fieldLabel":"No answer"],
        ]]
    }
}

/// This is declared as an open class to allow for serialization of custom `jsonChoices` with a
/// serialization pattern that matches the requirements of Kotlin serialization. In Kotlin, there
/// is a one-to-one mapping of the "type" keyword to class. Since the `jsonChoice` objects all
/// require using the same class type for the choices, requiring those json maps to include a "type"
/// keyword would be brittle for human-edited json files. Therefore, instead, the "type" field is
/// defined at this level with an encoded `baseType` and an overridable method for decoding the
/// the choices.
open class ChoiceQuestionStepObject : AbstractQuestionStep, ChoiceQuestion, QuestionStep, Encodable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case jsonChoices = "choices", baseType, isSingleAnswer = "singleChoice", inputUIHint = "uiHint"
    }
    public static var jsonChoicesCodingKey : CodingKey { CodingKeys.jsonChoices }
    
    open private(set) var jsonChoices: [JsonChoice]
    open private(set) var baseType: JsonType = .string
    open private(set) var inputUIHint: RSDFormUIHint = .list
    open private(set) var isSingleAnswer: Bool = true
    
    public init(identifier: String,
                choices: [JsonChoice],
                isSingleAnswer: Bool = true,
                inputUIHint: RSDFormUIHint = .list,
                nextStepIdentifier: String? = nil) {
        self.jsonChoices = choices
        self.baseType = choices.first(where: {
            $0.matchingValue != nil && $0.matchingValue != JsonElement.null
        })!.matchingValue!.jsonType
        self.isSingleAnswer = isSingleAnswer
        self.inputUIHint = inputUIHint
        super.init(identifier: identifier, nextStepIdentifier: nextStepIdentifier)
    }
    
    public required init(identifier: String, type: RSDStepType?) {
        self.jsonChoices = []
        super.init(identifier: identifier, type: type)
    }
    
    public required init(from decoder: Decoder) throws {
        self.jsonChoices = []
        try super.init(from: decoder)
    }
    
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.inputUIHint = try container.decodeIfPresent(RSDFormUIHint.self, forKey: .inputUIHint) ?? self.inputUIHint
        
        // The following are only applicable at the base level and not dependent on the device type.
        guard deviceType == nil else { return }
        
        self.baseType = try container.decodeIfPresent(JsonType.self, forKey: .baseType) ?? type(of: self).defaultBaseType()
        self.isSingleAnswer = try container.decodeIfPresent(Bool.self, forKey: .isSingleAnswer) ?? self.isSingleAnswer
        
        var nestedContainer = try container.nestedUnkeyedContainer(forKey: .jsonChoices)
        var choices = [JsonChoice]()
        while !nestedContainer.isAtEnd {
            let nestedDecoder = try nestedContainer.superDecoder()
            let choice = try decodeJsonChoice(from: nestedDecoder)
            choices.append(choice)
        }
        try choices.forEach {
            guard $0.matchingValue == nil || $0.matchingValue!.jsonType == self.baseType else {
                let debugDescription = "The `matchingValue` of \($0) does not match the \(self.baseType)"
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.baseType,
                                                               in: container,
                                                               debugDescription: debugDescription)
            }
        }
        self.jsonChoices = choices
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? ChoiceQuestionStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.jsonChoices = self.jsonChoices
        subclassCopy.baseType = self.baseType
        subclassCopy.inputUIHint = self.inputUIHint
        subclassCopy.isSingleAnswer = self.isSingleAnswer
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.baseType, forKey: .baseType)
        try container.encode(self.inputUIHint, forKey: .inputUIHint)
        try container.encode(self.isSingleAnswer, forKey: .isSingleAnswer)
        try encodeJsonChoices(to: container.nestedUnkeyedContainer(forKey: .jsonChoices))
    }
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    public override class func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else {
            return super.isRequired(codingKey)
        }
        return key == .jsonChoices
    }
    
    // Override these methods to implement a *different* JsonChoice with a custom choice question.
    
    override open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .jsonChoices:
            return .init(propertyType: .referenceArray(JsonChoiceObject.documentableType()))
        case .baseType:
            return .init(propertyType: .reference(JsonType.documentableType()))
        case .isSingleAnswer:
            return .init(propertyType: .primitive(.boolean))
        case .inputUIHint:
            return .init(propertyType: .reference(RSDFormUIHint.documentableType()))
        }
    }
    
    override open class func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "optional": false,
            "singleChoice": false,
            "baseType": "integer",
            "uiHint": "checkmark",
            "choices":[
                ["text":"choice 1","icon":"choice1","value":1],
                ["text":"choice 2","value":2],
                ["text":"choice 3","value":3],
                ["text":"none of the above","exclusive":true]
            ],
            "surveyRules": [[ "matchingAnswer": 0]]
        ]]
    }
    
    open override class func defaultType() -> RSDStepType {
        .choiceQuestion
    }
    
    open class func defaultBaseType() -> JsonType {
        .string
    }
    
    open func decodeJsonChoice(from decoder: Decoder) throws -> JsonChoice {
        try JsonChoiceObject(from: decoder)
    }
    
    open func encodeJsonChoices(to container: UnkeyedEncodingContainer) throws {
        var nestedContainer = container
        try jsonChoices.forEach {
            guard let encodable = $0 as? Encodable else {
                let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "\($0) Does not conform to the Encodable protocol.")
                throw EncodingError.invalidValue($0, context)
            }
            let nestedEncoder = nestedContainer.superEncoder()
            try encodable.encode(to: nestedEncoder)
        }
    }
}

public final class StringChoiceQuestionStepObject : ChoiceQuestionStepObject {
    public override class func defaultType() -> RSDStepType {
        .stringChoiceQuestion
    }
    
    public override class func defaultBaseType() -> JsonType {
        .string
    }
    
    public override func decodeJsonChoice(from decoder: Decoder) throws -> JsonChoice {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        return JsonChoiceObject(text: value)
    }
    
    public override func encodeJsonChoices(to container: UnkeyedEncodingContainer) throws {
        var nestedContainer = container
        try jsonChoices.forEach {
            try nestedContainer.encode($0.text)
        }
    }
    
    override public class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard codingKey.stringValue == jsonChoicesCodingKey.stringValue else {
            return try super.documentProperty(for: codingKey)
        }
        return .init(propertyType: .primitiveArray(.string))
    }
    
    override public class func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "optional": false,
            "singleChoice": false,
            "uiHint": "checkmark",
            "choices":["choice 1","choice 2","choice 3"]
        ]]
    }
}
