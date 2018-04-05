//
//  MCTOverviewStepObject.swift
//  MotorControl
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

open class MCTOverviewStepObject : RSDOverviewStepObject {
    
    private enum CodingKeys: String, CodingKey {
        case icons
    }
    
    open var icons: [MCTIconInfo]?
    
    /// Override the copy into method.
    override open func copyInto(_ copy: RSDUIStepObject, userInfo: [String : Any]?) throws {
        try super.copyInto(copy, userInfo: nil)
        guard let subclassCopy = copy as? MCTOverviewStepObject else {
            assertionFailure("Failed to copy into a class of expected type.")
            return
        }
        subclassCopy.icons = self.icons
    }
    
    /// Override the decoder to also decode the icon types that this step will display.
    override open func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        guard deviceType == nil else { return }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.icons = try container.decodeIfPresent([MCTIconInfo].self, forKey: .icons)
    }
}

public struct MCTIconInfo : Codable {
    public let title: String
    public let icon: RSDImageWrapper
}
