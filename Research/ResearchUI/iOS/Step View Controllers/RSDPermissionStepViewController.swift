//
//  PermissionStepViewController.swift
//  ResearchUI (iOS)
//

import UIKit
import Research
import MobilePassiveData

@available(*,deprecated, message: "Will be deleted in a future version.")
open class PermissionStepViewModel: RSDStepViewModel {
    
    /// Flag indicating the authorization status for this step.
    public fileprivate(set) var authorizationStatus: PermissionAuthorizationStatus?
    
    /// Override the forward button to disable until the status is checked.
    override open var isForwardEnabled: Bool {
        return super.isForwardEnabled && !(authorizationStatus?.isDenied() ?? true)
    }
}

/// `PermissionStepViewController` is a customizable view controller that is designed to be used to
/// request and/or check the permission status for this view.
@available(*,deprecated, message: "Will be deleted in a future version.")
open class PermissionStepViewController: RSDStepViewController {
    
    override open func instantiateStepViewModel(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepViewPathComponent {
        return PermissionStepViewModel(step: step, parent: parent)
    }
    
    /// Override viewDidAppear to set up notification handling.
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check the authorization status but to not request if not yet denied.
        _updateAuthorizationStatus()
    }
    
    // MARK: Permission handling
    
    private var _authStatus: PermissionAuthorizationStatus? {
        get {
            return (self.stepViewModel as? PermissionStepViewModel)?.authorizationStatus
        }
        set {
            (self.stepViewModel as? PermissionStepViewModel)?.authorizationStatus = newValue
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
                PermissionAuthorizationHandler.requestAuthorization(for: permission) { [weak self] (status, _) in
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
    override open func handleAuthorizationFailed(status: PermissionAuthorizationStatus, permission: StandardPermission) {
        _authStatus = status
        super.handleAuthorizationFailed(status: status, permission: permission)
    }
    
    /// Override goForward to add in requesting permissions before continuing.
    override open func goForward() {
        guard let permissions = self.requestedPermissions(), permissions.count > 0 else {
            super.goForward()
            return
        }
        
        let requests = permissions.compactMap { (permission) -> StandardPermission? in
            let status = self.authorizationStatus(for: permission.permissionType)
            return (status == .notDetermined) ? permission : nil
        }
        
        self.requestPermissions(requests) { [weak self] (status, permission) in
            DispatchQueue.main.async {
                if status.isDenied(), !(permission?.isOptional ?? false) {
                    self?.handleAuthorizationFailed(status: status, permission: permission!)
                } else {
                    self?._super_goForward()
                }
            }
        }
    }
    
    /// Request the given permissions and then call the completion once *all* permssions are requested.
    ///
    /// - note: syoung 04/04/2019 This implementation is currently limited to *only* requesting certain
    /// permissions using this method. For certain permission types, the requesting flow is complicated
    /// enough that trying to generalize the handling and the messaging is not appropriate.
    ///
    /// - parameters:
    ///     - permissions: The permissions to be requested.
    ///     - completion: The completion handler to call when finished.
    open func requestPermissions(_ permissions: [StandardPermission], _ completion: @escaping ((PermissionAuthorizationStatus, StandardPermission?) -> Void)) {
        guard permissions.count <= 1 else {
            assertionFailure("This step view controller is intended to be able to handle requesting a single permission. Handling multiple permissions requires managing the alerts serially.")
            completion(.authorized, nil)
            return
        }
        
        guard let permission = permissions.first else {
            completion(.authorized, nil)
            return
        }
        
        PermissionAuthorizationHandler.requestAuthorization(for: permission) { (status, _) in
            completion(status, permission)
        }
    }
    
    func _super_goForward() {
        super.goForward()
    }

}
