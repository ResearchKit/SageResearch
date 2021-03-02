//
//  TaskPresentationViewController.swift
//  RSDCatalog
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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
import ResearchUI
import JsonModel
import Research

/// The data storage manager in this case is used to show a sample usage. As such, the data will not be
/// shared to user defaults but only in local memory.
class DataStorageManager : NSObject, RSDDataStorageManager {
    
    static let shared = DataStorageManager()
    
    var taskData: [RSDIdentifier : RSDTaskData] = [:]
    
    func previousTaskData(for taskIdentifier: RSDIdentifier) -> RSDTaskData? {
        return taskData[taskIdentifier]
    }
    
    func saveTaskData(_ data: RSDTaskData, from taskResult: RSDTaskResult?) {
        taskData[RSDIdentifier(rawValue: data.identifier)] = data
    }
}

class TaskPresentationViewController: UITableViewController, RSDTaskViewControllerDelegate {
    
    var taskInfo: RSDTaskInfo!
    var result: ResultData?
    let archiveManager = ArchiveManager()
    var firstAppearance: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppearance, (self.result == nil), let taskInfo = self.taskInfo {
            let taskViewModel = RSDTaskViewModel(taskInfo: taskInfo)
            taskViewModel.dataManager = DataStorageManager.shared
            let taskViewController = RSDTaskViewController(taskViewModel: taskViewModel)
            taskViewController.delegate = self
            self.present(taskViewController, animated: true, completion: nil)
        }
        firstAppearance = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ResultTableViewController, let result = self.result {
            vc.result = result
            vc.title = vc.result!.identifier
            vc.navigationItem.title = vc.title
        }
        else if let vc = segue.destination as? TaskArchivesTableViewController {
            vc.archiveManager = self.archiveManager
            vc.title = self.title
            vc.navigationItem.title = vc.title
        }
    }
    
    // MARK: - RSDTaskControllerDelegate
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        
        // populate the results
        self.result = taskController.taskViewModel.taskResult
        self.tableView.reloadData()
        
        // dismiss the view controller
        (taskController as? UIViewController)?.dismiss(animated: true) {
        }
        
        var debugResult: String = self.result!.identifier
        debugResult.append("\n\n=== Completed: \(reason) error:\(String(describing: error))")
        print(debugResult)
        
        // - note: The calling application is responsible for deleting the output directory once the files
        // are processed by encrypting them locally. The encrypted files can then be stored for upload
        // to a server or cloud service. These files are **not** encrypted so depending upon the
        // application, there is a risk of exposing PII data stored in these files.
        // For a production app, the cleanup method should be called for for the case where the participant
        // has exited the task early, cancelled the task, or there was a failure. Additionally, if using the
        // task result directly rather than the archiving the data using the archiving protocols, the cleanup
        // method should be called following upload either here or from `readyToSave`. syoung 04/22/2019
        //
        // taskController.taskViewModel.cleanup()
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        print("\n\n=== Ready to Save: \(taskViewModel.description)")
        
        taskViewModel.archiveResults(with: self.archiveManager) { (error) in
            print("Archive complete with \(self.archiveManager.dataArchives.count) archives. error:\(String(describing: error))")
        }
    }
    
    func taskViewController(_ taskViewController: UIViewController, shouldShowTaskInfoFor step: Any) -> Bool {
        // TODO: syoung 01/18/2019 clean up JSON and Factory stuff for showing the intro step.
        return false
    }
}
