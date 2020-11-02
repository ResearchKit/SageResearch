//
//  RSDPermissionStepViewController.swift
//  ResearchUI (iOS)
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

import UIKit
import Research

open class RSDPermissionStepViewModel: RSDStepViewModel {
    
    /// Flag indicating the authorization status for this step.
    public fileprivate(set) var authorizationStatus: RSDAuthorizationStatus?
    
    /// Override the forward button to disable until the status is checked.
    override open var isForwardEnabled: Bool {
        return super.isForwardEnabled && !(authorizationStatus?.isDenied() ?? true)
    }
}

/// `RSDPermissionStepViewController` is a customizable view controller that is designed to be used to
/// request and/or check the permission status for this view.
open class RSDPermissionStepViewController: RSDStepViewController {
    
    override open func instantiateStepViewModel(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepViewPathComponent {
        return RSDPermissionStepViewModel(step: step, parent: parent)
    }
    
    /// Override viewDidAppear to set up notification handling.
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check the authorization status but to not request if not yet denied.
        _updateAuthorizationStatus()
    }
    
    // MARK: Permission handling
    
    private var _authStatus: RSDAuthorizationStatus? {
        get {
            return (self.stepViewModel as? RSDPermissionStepViewModel)?.authorizationStatus
        }
        set {
            (self.stepViewModel as? RSDPermissionStepViewModel)?.authorizationStatus = newValue
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
                RSDAuthorizationHandler.requestAuthorization(for: permission) { [weak self] (status, _) in
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
    override open func handleAuthorizationFailed(status: RSDAuthorizationStatus, permission: RSDStandardPermission) {
        _authStatus = status
        super.handleAuthorizationFailed(status: status, permission: permission)
    }
    
    /// Override goForward to add in requesting permissions before continuing.
    override open func goForward() {
        guard let permissions = self.requestedPermissions(), permissions.count > 0 else {
            super.goForward()
            return
        }
        
        let requests = permissions.compactMap { (permission) -> RSDStandardPermission? in
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
    open func requestPermissions(_ permissions: [RSDStandardPermission], _ completion: @escaping ((RSDAuthorizationStatus, RSDStandardPermission?) -> Void)) {
        guard permissions.count <= 1 else {
            assertionFailure("This step view controller is intended to be able to handle requesting a single permission. Handling multiple permissions requires managing the alerts serially.")
            completion(.authorized, nil)
            return
        }
        
        guard let permission = permissions.first else {
            completion(.authorized, nil)
            return
        }
        
        RSDAuthorizationHandler.requestAuthorization(for: permission) { (status, _) in
            completion(status, permission)
        }
    }
    
    func _super_goForward() {
        super.goForward()
    }

}
