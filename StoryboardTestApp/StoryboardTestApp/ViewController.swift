//
//  ViewController.swift
//
//

import UIKit
import Research
import ResearchUI

class ViewController: UIViewController, RSDTaskViewControllerDelegate {
    
    @IBAction func showPortrait() {
        let vc = RSDTaskViewController(task: CustomTask(.portrait))
        vc.delegate = self
        self.presentModal(vc, animated: true) {}
    }
    
    @IBAction func showLandscape() {
        let vc = RSDTaskViewController(task: CustomTask(.landscape))
        vc.delegate = self
        self.presentModal(vc, animated: true) {}
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        (taskController as? UIViewController)?.dismiss(animated: true) {
        }
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        // do nothing
    }
}

