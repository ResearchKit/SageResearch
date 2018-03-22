//
//  ResultTableViewController.swift
//  RSDCatalog
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
import ResearchStack2UI
import ResearchStack2

class ResultTableViewController: UITableViewController, RSDTaskViewControllerDelegate {

    var taskPath: RSDTaskPath?
    var result: RSDResult?
    var firstAppearance: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppearance, (self.result == nil), let taskPath = self.taskPath {
            let taskViewController = RSDTaskViewController(taskPath: taskPath)
            taskViewController.delegate = self
            self.present(taskViewController, animated: true, completion: nil)
        }
        firstAppearance = false
    }

    // MARK: - Table view data source
    
    func results(in section: Int) -> [RSDResult] {
        if let collectionResult = result as? RSDCollectionResult {
            return collectionResult.inputResults
        } else if let taskResult = result as? RSDTaskResult {
            if section == 0 {
                return taskResult.stepHistory
            } else {
                return taskResult.asyncResults ?? []
            }
        } else {
            return []
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = result as? RSDCollectionResult {
            return 1
        } else if let taskResult = result as? RSDTaskResult {
            return (taskResult.asyncResults?.count ?? 0) > 0 ? 2 : 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results(in: section).count
    }
    
    enum ReuseIdentifier : String {
        case base
        case answer
        case file
        case section
        case error
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageTableViewCell
        let result = results(in: indexPath.section)[indexPath.row]
        if let answerResult = result as? RSDAnswerResult {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.answer.stringValue, for: indexPath) as! ImageTableViewCell
            cell.subtitleLabel?.text = answerResult.value != nil ? String(describing: answerResult.value!) : "nil"
        } else if let fileResult = result as? RSDFileResult {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.file.stringValue, for: indexPath) as! ImageTableViewCell
            cell.subtitleLabel?.text = fileResult.url != nil ? String(describing: fileResult.url!.lastPathComponent) : "nil"
        } else if (result is RSDCollectionResult) || (result is RSDTaskResult) {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.section.stringValue, for: indexPath) as! ImageTableViewCell
        } else if let errorResult = result as? RSDErrorResult {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.error.stringValue, for: indexPath) as! ImageTableViewCell
            cell.subtitleLabel?.text = errorResult.errorDescription
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.base.stringValue, for: indexPath) as! ImageTableViewCell
        }
        cell.titleLabel?.text = result.identifier
        return cell
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) else {
                return
        }
        
        if let vc = segue.destination as? ResultTableViewController {
            vc.result = results(in: indexPath.section)[indexPath.row]
            vc.title = vc.result!.identifier
            vc.navigationItem.title = vc.title
        }
        else if let vc = segue.destination as? FileResultViewController {
            vc.result = results(in: indexPath.section)[indexPath.row] as? RSDFileResult
            vc.title = vc.result!.identifier
            vc.navigationItem.title = vc.title
        }
    }
    
    // MARK: - RSDTaskControllerDelegate
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        
        // populate the results
        self.result = taskController.taskResult
        self.tableView.reloadData()
        
        // dismiss the view controller
        (taskController as? UIViewController)?.dismiss(animated: true) {
        }
        
        var debugResult: String = taskController.taskResult.identifier
        debugResult.append("\n\n=== Completed: \(reason) error:\(String(describing: error))")
        print(debugResult)
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskPath: RSDTaskPath) {
        print("\n\n=== Ready to Save: \(taskPath.description)")
        
        taskPath.archiveResults(with: CRFArchiveManager.shared) {
        }
    }
    
    func taskController(_ taskController: RSDTaskController, asyncActionControllerFor configuration: RSDAsyncActionConfiguration) -> RSDAsyncActionController? {
        return nil
    }
    
    func taskViewController(_ taskViewController: UIViewController, shouldShowTaskInfoFor step: Any) -> Bool {
        return true
    }
}
