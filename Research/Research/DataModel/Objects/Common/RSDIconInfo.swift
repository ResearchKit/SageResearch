//
//  RSDIconInfo.swift
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
import JsonModel

/// The icon info is a simple image holder that also contains a title and subtitle for the image.
public struct RSDIconInfo : Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case title, subtitle, icon
    }
    
    /// Title for the image.
    public let title: String
    
    /// Subtitle for the image.
    public let subtitle: String?
    
    /// The icon for this info object.
    public let icon: RSDResourceImageDataObject?
}

extension RSDIconInfo : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .title
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .title, .subtitle:
            return .init(propertyType: .primitive(.string))
        case .icon:
            return .init(propertyType: .reference(RSDResourceImageDataObject.documentableType()))
        }
    }
    
    public static func examples() -> [RSDIconInfo] {
        [RSDIconInfo(title: "Foo", subtitle: "ba", icon: RSDResourceImageDataObject(imageName: "foo"))]
    }
}
