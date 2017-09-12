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

/**
 The `SRSUIAction` protocol can be used to customize the title and image displayed for a 
 given action of the UI.
 */
public protocol SRSUIAction {
        
    var actionType: SRSUIActionType { get }
    
    var buttonTitle: String? { get }
    
    var buttonIcon: UIImage? { get }
}

/**
 The `SRSUIActionType` enum describes standard navigation actions that are common to a
 given UI step. It is extendable using the custom field.
 */
public enum SRSUIActionType {
    
    case navigation(Navigation)
    public enum Navigation : String {
        case goForward
        case goBackward
        case skip
        case cancel
        case learnMore
    }

    case custom(String)
}

extension SRSUIActionType: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: RawValue) {
        if let subtype = Navigation(rawValue: rawValue) {
            self = .navigation(subtype)
        }
        else {
            self = .custom(rawValue)
        }
    }
    
    public var rawValue: String {
        switch (self) {
        case .navigation(let value):
            return value.rawValue
            
        case .custom(let value):
            return value
        }
    }
}

extension SRSUIActionType: Hashable {

    public var hashValue: Int {
        return rawValue.hashValue
    }
}
