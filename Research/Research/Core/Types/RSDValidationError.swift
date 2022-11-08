//
//  RSDValidationError.swift
//  Research
//

import Foundation

/// `RSDValidationError` errors are thrown during validation of a task, step, etc.
/// Usually this happens during the decoding of the task or when the task is first
/// started.
///
public enum RSDValidationError : Error {
    
    /// Attempting to load a section, task, or input form with non-unique identifiers.
    case notUniqueIdentifiers(String)
    
    /// The image could not be found in the resource bundle.
    case invalidImageName(String)
    
    /// The given duration is invalid.
    case invalidDuration(String)
    
    /// The factory cannot decode an object because the class type is undefined.
    case undefinedClassType(String)
    
    /// Unsupported data type.
    case invalidType(String)
    
    case invalidValue(Any?, String)
    
    /// Expected identifier was not found.
    case identifierNotFound(Any, String, String)
    
    /// A forced optional unwrapped with a nil value.
    case unexpectedNullObject(String)
    
    /// The domain of the error.
    public static var errorDomain: String {
        return "RSDValidationErrorDomain"
    }
    
    /// The error code within the given domain.
    public var errorCode: Int {
        switch(self) {
        case .notUniqueIdentifiers(_):
            return -1
        case .invalidImageName(_):
            return -2
        case .invalidDuration(_):
            return -3
        case .undefinedClassType(_):
            return -4
        case .invalidType(_):
            return -5
        case .identifierNotFound(_, _, _):
            return -6
        case .unexpectedNullObject(_):
            return -7
        case .invalidValue(_, _):
            return -8
        }
    }
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        let description: String
        switch(self) {
        case .notUniqueIdentifiers(let str): description = str
        case .invalidImageName(let str): description = str
        case .invalidDuration(let str): description = str
        case .undefinedClassType(let str): description = str
        case .invalidType(let str): description = str
        case .identifierNotFound(_, _, let str): description = str
        case .unexpectedNullObject(let str): description = str
        case .invalidValue(_, let str): description = str
        }
        return ["NSDebugDescription": description]
    }
}
