//
//  RSDInstructionStepObject.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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


/// `RSDInstructionStepObject` extends the `RSDUIStepObject` to include additional information about an
/// active task. Specifically, this step is used to show instructions, including describing required
/// permissions that may need to be requested within the context of this step.
open class RSDInstructionStepObject : RSDUIStepObject, RSDStandardPermissionsStep, RSDInstructionStep {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case permissions, requestIfNeeded, fullInstructionsOnly
    }
    
    /// The permissions used by this task.
    open var standardPermissions: [RSDStandardPermission]?
    
    /// Should the step request the listed permissions before continuing to the next step, or should the
    /// step only check that none of the listed permissions have been denied or restricted?
    /// (Default == `false`)
    open var requestIfNeeded: Bool = false
    
    /// Should this step be displayed if and only if the flag has been set for displaying the full
    /// instructions? 
    open var fullInstructionsOnly: Bool = false
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? RSDOverviewStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.standardPermissions = self.standardPermissions
        subclassCopy.requestIfNeeded = self.requestIfNeeded
        subclassCopy.fullInstructionsOnly = self.fullInstructionsOnly
    }
    
    /// Override the decoder per device type b/c the task may require a different set of permissions depending upon the device.
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.standardPermissions = try container.decodeIfPresent([RSDStandardPermission].self, forKey: .permissions) ?? self.standardPermissions
        self.requestIfNeeded = try container.decodeIfPresent(Bool.self, forKey: .requestIfNeeded) ?? self.requestIfNeeded
        self.fullInstructionsOnly = try container.decodeIfPresent(Bool.self, forKey: .fullInstructionsOnly) ?? self.fullInstructionsOnly
    }
    
    // Overrides must be defined in the base implementation
    
    override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override class func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
            "identifier": "foo",
            "type": "active",
            "title": "Hello World!",
            "text": "Some text.",
            "permissions" : [["permissionType": "location"]],
            "requestIfNeeded" : true,
            "fullInstructionsOnly" : true
        ]
        
        return [jsonA]
    }
}
