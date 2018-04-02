//
//  ViewController.swift
//  ResearchStack2TestApp
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
import ResearchStack2
import ResearchStack2UI

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
        var taskInfoStep = RSDTaskInfoStepObject(with: RSDTaskInfoObject(with: "foo"))
        taskInfoStep.taskTransformer = RSDResourceTransformerObject(resourceName: "TaskFoo")
        let taskViewController = RSDTaskViewController(taskInfo: taskInfoStep)
        taskViewController.delegate = self
        self.present(taskViewController, animated: true, completion: nil)
    }
    
    
    // Mark: RSDTaskViewControllerDelegate
    
    let offMainQueue = DispatchQueue(label: "org.sagebase.ResearchStack2.Serialized.\(UUID())")
    
    open func deleteOutputDirectory(_ outputDirectory: URL?) {
        guard let outputDirectory = outputDirectory else { return }
        do {
            try FileManager.default.removeItem(at: outputDirectory)
        } catch let error {
            print("Error removing output directory: \(error.localizedDescription)")
            debugPrint("\tat: \(outputDirectory)")
        }
    }
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        
        // dismiss the view controller
        let outputDirectory = taskController.taskPath.outputDirectory
        (taskController as? UIViewController)?.dismiss(animated: true) {
            self.offMainQueue.async {
                self.deleteOutputDirectory(outputDirectory)
            }
        }
        
        var debugResult: String = taskController.taskResult.identifier
        debugResult.append("\n\n=== Completed: \(reason) error:\(String(describing: error))")
        print(debugResult)
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskPath: RSDTaskPath) {
        var debugResult: String = taskPath.description
        
        do {
            let encoder = RSDFactory.shared.createJSONEncoder()
            let taskJSON = try taskPath.encodeResult(to: encoder)
            if let string = String(data: taskJSON, encoding: .utf8) {
                debugResult.append("\n\n\(string)")
            }
        } catch let error {
            debugResult.append("\n\n=== Failed to encode the result: \(error)")
        }
        
        print(debugResult)
    }
    
    func taskController(_ taskController: RSDTaskController, asyncActionControllerFor configuration: RSDAsyncActionConfiguration) -> RSDAsyncActionController? {
        return nil
    }
    
    func taskViewController(_ taskViewController: UIViewController, shouldShowTaskInfoFor step: Any) -> Bool {
        return false
    }
}

