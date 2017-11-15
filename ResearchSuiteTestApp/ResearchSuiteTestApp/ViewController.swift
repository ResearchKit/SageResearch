//
//  ViewController.swift
//  ResearchSuiteTestApp
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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
import ResearchSuite
import ResearchSuiteUI

class ViewController: UIViewController, RSDTaskViewControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func runFooTask(_ sender: Any) {
        var taskInfo = RSDTaskInfoStepObject(with: "foo")
        taskInfo.taskTransformer = RSDResourceTransformerObject(resourceName: "TaskFoo")
        taskInfo.title = "Da Foo"
        taskInfo.subtitle = "In da house"
        taskInfo.icon = try! RSDImageWrapper(imageName: "activityIcon")
        taskInfo.detail = "This is an example task created by loading the task info from a resource."
        let taskViewController = RSDTaskViewController(taskInfo: taskInfo)
        taskViewController.delegate = self
        self.present(taskViewController, animated: true, completion: nil)
    }
    
    // MARK: RSDTaskViewControllerDelegate
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        
        // dismiss the view controller
        taskViewController.dismiss(animated: true, completion: nil)
        
        var debugResult: String = taskViewController.taskPath.description
        
        if reason == .completed {
            do {
                let encoder = RSDFactory.shared.createJSONEncoder()
                let taskJSON = try taskViewController.taskPath.encodeResult(to: encoder)
                if let string = String(data: taskJSON, encoding: .utf8) {
                    debugResult.append("\n\n\(string)")
                }
            } catch let error {
                debugResult.append("\n\n=== Failed to encode the result: \(error)")
            }
        }
        else {
            debugResult.append("\n\n=== Failed: \(String(describing: error))")
        }
        
        textView.text = debugResult
    }
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), viewControllerFor step: RSDStep) -> (UIViewController & RSDStepController)? {
        return nil
    }
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), viewControllerFor taskInfo: RSDTaskInfoStep) -> (UIViewController & RSDStepController)? {
        return nil
    }
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), asyncActionControllerFor configuration: RSDAsyncActionConfiguration) -> RSDAsyncActionController? {
        return nil
    }
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), readyToSave taskPath: RSDTaskPath) {
        // do nothing
    }
    
    func taskViewControllerShouldAutomaticallyForward(_ taskViewController: (UIViewController & RSDTaskController)) -> Bool {
        return false
    }
}

