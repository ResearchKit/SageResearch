//
//  RSDOverviewStepViewController.swift
//  ResearchUI (iOS)
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

import UIKit
import UserNotifications

open class RSDOverviewStepViewModel: RSDStepViewModel {
    
    public fileprivate(set) var authorizationStatus: RSDAuthorizationStatus?
    
    /// Override the forward button to disable until the status is checked.
    override open var isForwardEnabled: Bool {
        return super.isForwardEnabled && !(authorizationStatus?.isDenied() ?? true)
    }
}

/// `RSDOverviewStepViewController` is a customizable view controller that is designed to be the first view
/// displayed for an active task that may require checking the user's permissions and allows the user to set
/// a notification reminder to perform the task at a later time.
open class RSDOverviewStepViewController: RSDStepViewController {
    
    override open func instantiateStepViewModel(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepViewPathComponent {
        return RSDOverviewStepViewModel(step: step, parent: parent)
    }
    
    /// Override viewDidAppear to set up notification handling.
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check the authorization status
        _updateAuthorizationStatus()
        
        // If this is a reminder action then set that and keep a pointer to it.
        self.reminderAction = self.stepViewModel.action(for: .navigation(.skip)) as? RSDReminderUIAction
        
        // Remove any previous reminder.
        if let reminderIdentifier = reminderAction?.reminderIdentifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        }
    }
    
    
    // MARK: Permission handling

    private var _authStatus: RSDAuthorizationStatus? {
        get {
            return (self.stepViewModel as? RSDOverviewStepViewModel)?.authorizationStatus
        }
        set {
            (self.stepViewModel as? RSDOverviewStepViewModel)?.authorizationStatus = newValue
        }
    }
    
    /// Check authorization status.
    private func _updateAuthorizationStatus() {
        
        // Check the permission status for all required permissions. This will not **request** permission,
        // but will just check the current status. If permission is required for a step or async action
        // within this task, that permission should be requested at the appropriate time after explaining
        // to the participant why the permission is needed. The purpose of this check is to exit the task
        // early if the task cannot run and requires changing permission state.
        let (status, permission) = self.checkAuthorizationStatus()
        _authStatus = status
        if status.isDenied(), let permission = permission {
            if (permission.permissionType == .motion) && (status == .previouslyDenied) {
                // If this is a motion permission which was previously denied, then query the status to see
                // if this the forward enabled state should be changed.
                RSDMotionAuthorization.requestAuthorization() { [weak self] (status, _) in
                    self?._authStatus = status
                    if status.isDenied() {
                        self?.handleAuthorizationFailed(status: status, permission: permission)
                    } else {
                        self?.didFinishLoading()
                    }
                }
            }
            else {
                handleAuthorizationFailed(status: status, permission: permission)
            }
        } else {
            // Fire the did finish method.
            didFinishLoading()
        }
    }
    
    /// Present an alert letting the user know that they do not have authorizations that are required to run
    /// this task.
    open func handleAuthorizationFailed(status: RSDAuthorizationStatus, permission: RSDStandardPermission) {
        _authStatus = status
        
        let settingsMessage = (status == .restricted) ? permission.restrictedMessage : permission.deniedMessage
        let message: String = {
            guard let reason = permission.reason else { return settingsMessage }
            return "\(reason)\n\n\(settingsMessage)"
        }()
        self.presentAlertWithOk(title: "Not Authorized", message: message, actionHandler: nil)
    }
    

    // MARK: Reminder notification handling
    
    /// The reminder action associated with this step view controller.
    open private(set) var reminderAction: RSDReminderUIAction?
    
    /// Override skipForward to check if this is a reminder action for the skip button.
    open override func skipForward() {
        if let _ = reminderAction {
            _updateReminderNotification()
        } else {
            super.skipForward()
        }
    }
    
    /// Handle messaging the user that they have previously denied permission to show a local notification.
    open func handleNotificationAuthorizationDenied() {
        let title = Localization.localizedString("REMINDER_AUTH_DENIED_TITLE")
        let message = Localization.localizedString("REMINDER_AUTH_DENIED_MESSAGE")
        self.presentAlertWithOk(title: title, message: message) { (_) in
        }
    }
    
    /// Post an action sheet asking the user how long until they want to be reminded to do this task.
    open func remindMeLater() {

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour]
        formatter.unitsStyle = .full
        
        let actionNone = UIAlertAction(title: Localization.localizedString("REMINDER_CHOICE_NONE"), style: .cancel) { (_) in
            // Do nothing.
        }
        
        let action15min = UIAlertAction(title:
            Localization.localizedStringWithFormatKey("REMINDER_CHOICE_IN_DURATION_%@", formatter.string(from: 15 * 60)!), style: .default) { (_) in
            self.addReminder(timeInterval: 15 * 60)
        }
        
        let action1hr = UIAlertAction(title:
            Localization.localizedStringWithFormatKey("REMINDER_CHOICE_IN_DURATION_%@", formatter.string(from: 60 * 60)!), style: .default) { (_) in
            self.addReminder(timeInterval: 60 * 60)
        }
        let action2hr = UIAlertAction(title:
            Localization.localizedStringWithFormatKey("REMINDER_CHOICE_IN_DURATION_%@", formatter.string(from: 2 * 60 * 60)!), style: .default) { (_) in
            self.addReminder(timeInterval: 2 * 60 * 60)
        }
        
        let message = Localization.localizedString("REMINDER_CHOICE_SELECTION_PROMPT")

        self.presentAlertWithActions(title: nil, message: message, preferredStyle: .actionSheet, actions: [action2hr, action1hr, action15min, actionNone])
    }
    
    /// Add a reminder to perform this task that is triggered for a time in the future.
    open func addReminder(timeInterval: TimeInterval) {
        guard let reminderIdentifier = reminderAction?.reminderIdentifier else { return }
        
        let content = UNMutableNotificationContent()
        if let title = (self.step as? RSDTaskInfoStep)?.taskInfo.title ?? self.uiStep?.title {
            content.body = Localization.localizedStringWithFormatKey("REMINDER_NOTIFICATION_WITH_TITLE_%@", title)
        } else {
            content.body = Localization.localizedString("REMINDER_NOTIFICATION_WITHOUT_TITLE")
        }
        content.sound = UNNotificationSound.default
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            content.categoryIdentifier = "\(bundleIdentifier).RemindMeLater"
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        
        // Schedule the notification.
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                print("Failed to add notification for \(reminderIdentifier). \(error!)")
            }
            self.cancel()
        }
    }
    
    fileprivate func _updateReminderNotification() {
        
        // Check if this is the main thread and if not, then call it on the main thread.
        // The expectation is that if calling method is a button push, the response should be inline
        // and *not* at the bottom of the queue.
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self._updateReminderNotification()
            }
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?._requestAuthorization()
            case .denied:
                self?.handleNotificationAuthorizationDenied()
            case .authorized, .provisional:
                self?.remindMeLater()
            }
        }
    }
    
    fileprivate func _requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { [weak self] (granted, _) in
            DispatchQueue.main.async {
                if granted {
                    self?.remindMeLater()
                } else {
                    self?.cancel()
                }
            }
        }
    }
    
    
    // MARK: Initialization
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: RSDOverviewStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    open class var bundle: Bundle {
        return Bundle(for: RSDOverviewStepViewController.self)
    }
    
    /// Default initializer. This initializer will initialize using the `nibName` and `bundle` defined on this class.
    /// - parameter step: The step to set for this view controller.
    public override init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: type(of: self).nibName, bundle: type(of: self).bundle)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
    }
    
    /// Initialize the class using the given nib and bundle.
    /// - note: If this initializer is used with a `nil` nib, then it must assign the expected outlets.
    /// - parameters:
    ///     - nibNameOrNil: The name of the nib or `nil`.
    ///     - nibBundleOrNil: The name of the bundle or `nil`.
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Required initializer. This is the initializer used by a `UIStoryboard`.
    /// - parameter aDecoder: The decoder used to initialize this view controller.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
