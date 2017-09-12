//
//  SRSUIAction.swift
//  SageResearchSDK
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

public protocol SRSUIAction {
        
    var identifier: String { get }
    
    var buttonTitle: String? { get }
    
    var buttonIcon: UIImage? { get }
}

extension SRSUIAction {
    
    var actionType: SRSUIActionType {
        return SRSUIActionType(rawValue: self.identifier)
    }
}

public enum SRSUIActionType {
    
    case navigation(Navigation)
    public enum Navigation : String {
        case goForward
        case goBackward
        case skip
        case cancel
    }

    case custom(String)
    
    public init(rawValue: String) {
        if let subtype = Navigation(rawValue: rawValue) {
            self = .navigation(subtype)
        }
        else {
            self = .custom(rawValue)
        }
    }
}

extension SRSUIActionType: Equatable {
}

public func ==(lhs: SRSUIActionType, rhs: SRSUIActionType) -> Bool {
    switch (lhs, rhs) {
    case (.navigation(let lhsValue), .navigation(let rhsValue)):
        return lhsValue == rhsValue;
    case (.custom(let lhsValue), .custom(let rhsValue)):
        return lhsValue == rhsValue;
    default:
        return false
    }
}

extension SRSUIActionType: Hashable {
    public var hashValue: Int {
        switch (self) {
        case .navigation(let value):
            return value.hashValue;
        case .custom(let value):
            return value.hashValue;
        }
    }
}
