//
//  RSDOverviewStepViewController.swift
//  ResearchUI (iOS)
//

import UIKit
import UserNotifications
import Research

/// `RSDOverviewStepViewController` is a customizable view controller that is designed to be the first view
/// displayed for an active task that may require checking the user's permissions and allows the user to set
/// a notification reminder to perform the task at a later time.
@available(*,deprecated, message: "Will be deleted in a future version.")
@available(iOS 13.0, *)
open class RSDOverviewStepViewController: PermissionStepViewController {
    
    /// Override viewDidAppear to set up notification handling.
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If this is a reminder action then set that and keep a pointer to it.
        self.reminderAction = self.stepViewModel.action(for: .navigation(.skip)) as? RSDReminderUIAction
        
        // Remove any previous reminder.
        if let reminderIdentifier = reminderAction?.reminderIdentifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        }
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
            String.localizedStringWithFormat(Localization.localizedString("REMINDER_CHOICE_IN_DURATION_%@"), formatter.string(from: 15 * 60)!), style: .default) { (_) in
            self.addReminder(timeInterval: 15 * 60)
        }
        
        let action1hr = UIAlertAction(title:
            String.localizedStringWithFormat(Localization.localizedString("REMINDER_CHOICE_IN_DURATION_%@"), formatter.string(from: 60 * 60)!), style: .default) { (_) in
            self.addReminder(timeInterval: 60 * 60)
        }
        let action2hr = UIAlertAction(title:
            String.localizedStringWithFormat(Localization.localizedString("REMINDER_CHOICE_IN_DURATION_%@"), formatter.string(from: 2 * 60 * 60)!), style: .default) { (_) in
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
            content.body = String.localizedStringWithFormat(Localization.localizedString("REMINDER_NOTIFICATION_WITH_TITLE_%@"), title)
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
            case .authorized, .provisional, .ephemeral:
                self?.remindMeLater()
            @unknown default:
                self?.handleNotificationAuthorizationDenied()
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
    
    class func initializeStepViewController(step: RSDStep, parent: RSDPathComponent?) -> RSDOverviewStepViewController {
        return RSDScrollingOverviewStepViewController(step: step, parent: parent)
    }
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: RSDOverviewStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    open class var bundle: Bundle {
        return Bundle.module
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
