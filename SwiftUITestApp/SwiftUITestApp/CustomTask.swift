//
//  CustomTask.swift
//
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
        let step1 = InstructionStepObject(identifier: "step1")
        step1.title = "Step 1 - \(self.identifier)"
        step1.detail = "This is the first step."
        step1.imageTheme = RSDFetchableImageThemeElementObject(imageName: "cat1")
        let step1b = CustomStep(identifier: "step1b")
        let step2 = InstructionStepObject(identifier: "step2")
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
        ResultObject(identifier: self.identifier)
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

class InstructionStepObject : RSDUIStepObject {
    override class func defaultType() -> RSDStepType {
        return .instruction
    }
}
