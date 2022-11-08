//
//  RSDInputFieldError.swift
//  Research
//

import Foundation

/// `RSDInputFieldError` is used when validating a user-entered answer.
@available(*,deprecated, message: "Will be deleted in a future version.")
public enum RSDInputFieldError: Error {
    
    /// The context for the error.
    public struct Context {
        /// The identifier for the `RSDInputField`.
        public let identifier: String?
        /// The value being validated.
        public let value: Any?
        /// A debug description for the error.
        public let debugDescription: String
        
        public init(identifier: String?, value: Any?, debugDescription: String) {
            self.identifier = identifier
            self.value = value
            self.debugDescription = debugDescription
        }
    }
    
    /// The value entered cannot be converted to the expected answer type.
    case invalidType(Context)
    
    /// The formatter could not convert the value entered to the expected answer type.
    case invalidFormatter(Formatter, Context)
    
    /// The value entered does not match the regex for this field.
    case invalidRegex(String?, Context)
    
    /// The text value entered exceeds the maximum allowed length.
    case exceedsMaxLength(Int, Context)
    
    /// The numeric value entered is less than the minimum allowed value.
    case lessThanMinimumValue(Decimal, Context)
    
    /// The numeric value entered is greater than the maximum allowed value.
    case greaterThanMaximumValue(Decimal, Context)
    
    /// The date entered is less than the minimum allowed date.
    case lessThanMinimumDate(Date, Context)
    
    /// The date entered is greater than the maximum allowed date.
    case greaterThanMaximumDate(Date, Context)
    
    /// The domain of the error.
    public static var errorDomain: String {
        return "RSDInputFieldErrorDomain"
    }
    
    /// The error code within the given domain.
    public var errorCode: Int {
        switch(self) {
        case .invalidType(_):
            return -1
        case .invalidFormatter(_,_):
            return -2
        case .invalidRegex(_,_):
            return -3
        case .exceedsMaxLength(_,_):
            return -4
        case .lessThanMinimumValue(_,_), .greaterThanMaximumValue(_,_):
            return -6
        case .lessThanMinimumDate(_,_), .greaterThanMaximumDate(_,_):
            return -7
        }
    }
    
    /// The context for the error.
    public var context: Context {
        switch(self) {
        case .invalidType(let context):
            return context
        case .invalidFormatter(_, let context):
            return context
        case .invalidRegex(_, let context):
            return context
        case .exceedsMaxLength(_, let context):
            return context
        case .lessThanMinimumValue(_, let context):
            return context
        case .greaterThanMaximumValue(_, let context):
            return context
        case .lessThanMinimumDate(_, let context):
            return context
        case .greaterThanMaximumDate(_, let context):
            return context
        }
    }
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        let description: String = self.context.debugDescription
        return ["NSDebugDescription": description]
    }
}
