//
//  CRFTorchInstructionStepViewController.swift
//  CardiorespiratoryFitness
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

extension CRFTorchInstructionStep : RSDStepViewControllerVendor {
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        let vc = CRFTorchInstructionStepViewController(step: self, parent: parent)
        return vc
    }
}

class CRFTorchInstructionStepViewController: RSDInstructionStepViewController {
    
    private var _captureDevice: AVCaptureDevice?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request permission to turn on the camera flash.
        self.requestPermissions([.camera]) { [weak self] (status, _) in
            if status == .authorized {
                self?._turnOnTorch()
            }
            else {
                self?.handleAuthorizationFailed(status: status, permission: .camera)
            }
        }
    }
    
    private func _turnOnTorch() {
        DispatchQueue.main.async {
            do {
                guard let device = self._captureDevice ?? self._getCaptureDevice() else { return }
                try device.lockForConfiguration()
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                device.unlockForConfiguration()
                self._captureDevice = device
            } catch let err {
                debugPrint("Failed to turn ON the flash. \(err)")
            }
        }
    }
    
    private func _turnOffTorch() {
        DispatchQueue.main.async {
            do {
                guard let device = self._captureDevice else { return }
                try device.lockForConfiguration()
                device.torchMode = .auto
                device.unlockForConfiguration()
            } catch let err {
                debugPrint("Failed to turn OFF the flash. \(err)")
            }
            self._captureDevice = nil
        }
    }
    
    private func _getCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
    }
    
    override func cancelTask(shouldSave: Bool) {
        super.cancelTask(shouldSave: shouldSave)
        // If the user cancels the task, then we need to turn off the flash. Otherwise, can leave it on.
        _turnOffTorch()
    }
}
