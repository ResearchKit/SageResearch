//
//  RunDistanceStepViewController.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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

/// The step view controller for running the distance step in the 12 minute walk/run test or the 6 minute
/// endurance test.
public class CRFRunDistanceStepViewController: RSDActiveStepViewController {
    
    private var _distanceObserver: NSKeyValueObservation?
    
    /// The location recorder attached to this step.
    public var locationRecorder: RSDDistanceRecorder? {
        guard let taskController = self.stepViewModel?.rootPathComponent.taskController else {
            return nil
        }
        return taskController.currentAsyncControllers.first(where: { $0 is RSDDistanceRecorder }) as? RSDDistanceRecorder
    }
    
    /// Override the required permissions to return location if the super class returns nil.
    override public func requiredPermissions() -> [RSDStandardPermission]? {
        return super.requiredPermissions() ?? [RSDStandardPermission.location]
    }
    
    /// Override start to set up an observer of distance changes.
    override public func start() {
        super.start()
        
        // Set up an observer for changes to the location.
        if let locationRecorder = self.locationRecorder, locationRecorder.status != .failed {
            
            // Set the initial value
            self._updateDistanceLabelOnMainQueue(locationRecorder.totalDistance)
            
            // Add an observer
            _distanceObserver = locationRecorder.observe(\.totalDistance) { [weak self] (recorder, change) in
                self?._updateDistanceLabelOnMainQueue(recorder.totalDistance)
            }
        }
        else {
            // If we somehow got to this point without the task exiting early, apply belt and suspenders to
            // ensure that we are messaging the user that without the requested permissions they can't
            // continue. When using the full task that this step view controller is baked into, this is
            // handled by the `RSDOverviewStepViewController` (first step) but if a developer tried to use
            // this view controller without using the full task, this will alert them that they did something
            // wrong. syoung 3/16/2018
            let (status, _permission) = self.checkAuthorizationStatus()
            let permission = _permission ?? RSDStandardPermission.location
            let settingsMessage = (status == .restricted) ? permission.restrictedMessage : permission.deniedMessage
            let message: String = {
                guard let reason = permission.reason else { return settingsMessage }
                return "\(reason)\n\n\(settingsMessage)"
            }()
            self.presentAlertWithOk(title: nil, message: message, actionHandler: { (_) in
                self.cancel()
            })
        }
    }
    
    /// Override stop to invalidate the observer and add a distance result.
    override public func stop() {
        _distanceObserver?.invalidate()
        _distanceObserver = nil
        
        // Add the total distance as a result for display to the user
        var distanceResult = RSDAnswerResultObject(identifier: self.step.identifier, answerType: RSDAnswerResultType(baseType: .decimal))
        distanceResult.value = self.locationRecorder?.totalDistance
        self.stepViewModel.taskResult.appendStepHistory(with: distanceResult)
        
        super.stop()
    }
    
    func _updateDistanceLabelOnMainQueue(_ distance: Double) {
        DispatchQueue.main.async {
            self._updateDistanceLabel(distance)
        }
    }
    
    let usesMetricSystem: Bool = Locale.current.usesMetricSystem
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }()
    
    let unitFormatter: LengthFormatter = {
        let unitFormatter = LengthFormatter()
        unitFormatter.unitStyle = .long
        return unitFormatter
    }()
    
    func _updateDistanceLabel(_ distance: Double) {
        
        // update the label
        if usesMetricSystem {
            self.progressLabel?.text = numberFormatter.string(from: NSNumber(value: distance))
            self.unitLabel?.text = unitFormatter.unitString(fromValue: 100, unit: .meter).localizedUppercase
        } else {
            self.progressLabel?.text = numberFormatter.string(from: NSNumber(value: distance * 3.28084))
            self.unitLabel?.text = unitFormatter.unitString(fromValue: 100, unit: .foot).localizedUppercase
        }
        
        // fire the timer
        self.timerFired()
    }
}
