//
//  RSDOverviewStepObject.swift
//  Research
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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

/// `RSDOverviewStepObject` extends the `RSDUIStepObject` to include information about an activity including
/// what permissions are required by this task. Without these preconditions, the task cannot measure or
/// collect the data needed for this task.
open class RSDOverviewStepObject : RSDUIStepObject, RSDOverviewStep, Encodable {

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case icons
    }
    
    /// For this implementation of the overview step, the learn more action is included in the
    /// readwrite dictionary of actions.
    open var learnMoreAction: RSDUIAction? {
        get {
            return self.actions?[.navigation(.learnMore)]
        }
        set {
            guard let action = newValue else {
                self.actions?[.navigation(.learnMore)] = nil
                return
            }
            var actions = self.actions ?? [:]
            actions[.navigation(.learnMore)] = action
            self.actions = actions
        }
    }
    
    /// The icons that are used to define the list of things you will need for an active task.
    /// These should *not* be readwrite since "What you will need" should be consistent across
    /// uses of the activity.
    open private(set) var icons: [RSDIconInfo]?
    
    /// Default type is `.overview`.
    open override class func defaultType() -> RSDStepType {
        return .overview
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? RSDOverviewStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.icons = self.icons
    }
    
    /// Override the decoder per device type b/c the task may require a different set of permissions depending upon the device.
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.icons = try container.decodeIfPresent([RSDIconInfo].self, forKey: .icons) ?? self.icons
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.icons, forKey: .icons)
    }
    
    // Overrides must be defined in the base implementation
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .icons:
            return .init(propertyType: .referenceArray(RSDIconInfo.documentableType()))
        }
    }
    
    override open class func jsonExamples() throws -> [[String : JsonSerializable]] {
        let jsonA: [String : JsonSerializable] = [
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "detail": "Some text.",
            "permissions" : [["permissionType": "location"]],
            "icons": [ [ "icon":"Foo1", "title": "A SMOOTH SURFACE"] ]
        ]
        
        return [jsonA]
    }
}
