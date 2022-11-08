//
//  RSDReminderUIAction.swift
//  Research
//

import Foundation


/// `RSDReminderUIAction` implements an action for setting up a local notification to remind
/// the participant about doing a particular task later.
public protocol RSDReminderUIAction : RSDUIAction {
    
    /// The identifier for a `UNNotificationRequest`.
    var reminderIdentifier: String { get }
}
