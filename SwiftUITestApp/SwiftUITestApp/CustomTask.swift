//
//  CustomTask.swift
//
//
//  Copyright © 2021 Sage Bionetworks. All rights reserved.
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
import MobilePassiveData
import JsonModel
import ResultModel
import Research
import ResearchUI

enum Orientation : String, Identifiable {
    case portrait, landscape
    var id: String { self.rawValue }
}

class CustomTask : RSDOrientationTask {
    
    let identifier: String
    let taskOrientation: UIInterfaceOrientationMask
    
    init(_ orientation: Orientation) {
        self.identifier = orientation.rawValue
        switch orientation {
        case .portrait:
            self.taskOrientation = .portrait
        case .landscape:
            self.taskOrientation = .landscape
        }
    }
    
    lazy var stepNavigator: RSDStepNavigator = {
        let step1 = RSDInstructionStepObject(identifier: "step1")
        step1.title = "Step 1 - \(self.identifier)"
        step1.detail = "This is the first step."
        step1.imageTheme = RSDFetchableImageThemeElementObject(imageName: "cat1")
        let step1b = CustomStep(identifier: "step1b")
        let step2 = RSDInstructionStepObject(identifier: "step2")
        step2.title = "Step 2 - \(self.identifier)"
        step2.detail = "This is the second step."
        step2.imageTheme = RSDFetchableImageThemeElementObject(imageName: "cat2")
        return RSDConditionalStepNavigatorObject(with: [step1, step1b, step2])
    }()
    
    func instantiateTaskResult() -> RSDTaskResult {
        RSDTaskResultObject(identifier: self.identifier)
    }
    
    var schemaInfo: RSDSchemaInfo? { nil }
    var asyncActions: [AsyncActionConfiguration]? { nil }
    
    func validate() throws {
    }
}

extension UIInterfaceOrientationMask {
    func names() -> [String] {
        let mapping: [String : UIInterfaceOrientationMask] = [
            "portrait" : .portrait,
            "landscape" : .landscape
        ]
        return mapping.compactMap { self.contains($0.value) ? $0.key : nil }
    }
}

struct CustomStep : RSDStepViewControllerVendor {
    let identifier: String
    
    let stepType: RSDStepType = "custom"
    
    func instantiateStepResult() -> ResultData {
        RSDResultObject(identifier: self.identifier)
    }
    
    func validate() throws {
    }
    
    func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CustomStepViewController") as! CustomStepViewController
        vc.stepViewModel = vc.instantiateStepViewModel(for: self, with: parent)
        return vc
    }
}

class CustomStepViewController : RSDStepViewController {
}

class PresentedViewController : UIViewController {
    @IBAction func dismissOverlay() {
        self.dismiss(animated: true) {
            print("view dismissed")
        }
    }
}
