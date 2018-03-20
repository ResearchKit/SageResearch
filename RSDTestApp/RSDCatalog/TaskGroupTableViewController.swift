//
//  TaskGroupTableViewController.swift
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
import ResearchStack2

class TaskGroupTableViewController: UITableViewController {

    /// The list of task groups included in this catalog.
    var taskGroups: [RSDTaskGroupObject]!
    
    override func viewDidLoad() {
        
        // Load the task groups *before* calling super (which loads the tableView)
        guard let path = Bundle.main.path(forResource: "TaskGroups", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            assertionFailure("Failed to open the TaskGroups JSON")
            return
        }
        RSDFactory.shared = CatalogFactory()
        let jsonDecoder = RSDFactory.shared.createJSONDecoder()
        do {
            taskGroups = try jsonDecoder.decode([RSDTaskGroupObject].self, from: jsonData)
        } catch let err {
            assertionFailure("Failed to decode the TaskGroups JSON: \(err)")
        }
        
        // Call super
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskGroups?.count ?? 0
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath) as! ImageTableViewCell
        let taskGroup = self.taskGroups[indexPath.row]
        cell.titleLabel?.text = taskGroup.title ?? taskGroup.identifier
        if let imageView = cell.thumbnailView {
            taskGroup.imageVendor?.fetchImage(for: imageView.bounds.size) { (_, img) in
                imageView.image = img
            }
        }
        return cell
     }

    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell),
            let vc = segue.destination as? TaskTableViewController
        else {
            return
        }
        vc.taskGroup = self.taskGroups[indexPath.row]
        vc.title = vc.taskGroup.title ?? vc.taskGroup.identifier
        vc.navigationItem.title = vc.title
     }
}

class ImageTableViewCell : UITableViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
}

