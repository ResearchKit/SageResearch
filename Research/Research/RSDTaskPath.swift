//
//  RSDTaskPath.swift
//  Research
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

import Foundation

/// `RSDTaskPath` is used to keep track of the current state of a running task.
///
/// - seealso: `RSDTaskController`
///
public final class RSDTaskPath : NSObject, NSCopying {

    /// The completion handler for a fetched task.
    public typealias FetchCompletionHandler = (RSDTaskPath, Error?) -> Void
    
    /// Identifier for this path segment
    public let identifier: String
    
    /// Identifier for this task that can be mapped back to a notification. This may be the same
    /// as the task identifier, or it might be that a task is scheduled multiple times per day,
    /// and the app needs to track what the scheduled timing is for the task.
    public var scheduleIdentifier: String?
    
    /// The tracking delegate is used to allow any task to reference a delegate that can be used to set up
    /// the task using the results of a previous run. Because a task path may be instantiated using either a
    /// task info object or by a task, it's possible that the `RSDTask` associated with the task has not yet
    /// been instantiated when the top-level task path is created.
    public weak var trackingDelegate: RSDTrackingDelegate? {
        didSet {
            self.setupTracking()
        }
    }
    
    //// String identifying the full path for this task.
    public var fullPath: String {
        let prefix = parentPath?.fullPath ?? ""
        return (prefix as NSString).appendingPathComponent(identifier)
    }
    
    /// String representing the current order of steps to this point in the task.
    public var stepPath: String {
        return self.result.stepHistory.map( {$0.identifier }).joined(separator: ", ")
    }
    
    /// The task info object used to load the task.
    public private(set) var taskInfo: RSDTaskInfoStep?
    
    /// The task that is currently being run.
    public private(set) var task: RSDTask?
    
    /// Convenience method for accessing the top-level task path.
    public var topLevelTaskPath: RSDTaskPath {
        var taskPath = self
        while let path = taskPath.parentPath {
            taskPath = path
        }
        return taskPath
    }
    
    /// The result associated with this task.
    public var result: RSDTaskResult
    
    /// A listing of step results that were removed from the task result. These results can be accessed
    /// by a step view controller to load a result that was previously selected.
    public private(set) var previousResults: [RSDResult]?
    
    /// The current step. If `nil` then the task has not been started.
    public var currentStep: RSDStep?
 
    /// This is a flag that can be used to mark whether or not the task is ready to be saved.
    public var isCompleted: Bool = false
    
    /// This is a flag that can be used to mark when a task was exited early.
    public var didExitEarly: Bool = false
    
    /// A pointer to a parent path if this is subtask step.
    public private(set) weak var parentPath: RSDTaskPath?
    private var _strongParent: RSDTaskPath?
    
    /// A pointer to the path sections visited
    public private(set) var childPaths: [String : RSDTaskPath] = [:]
    
    /// Flag for tracking whether or not the `task` is loading from the `taskInfo`.
    public private(set) var isLoading: Bool = false
    
    /// File URL for the directory in which to store generated data files. Asyncronous actions with
    /// recorders (and potentially steps) can save data to files during the progress of the task.
    /// This property specifies where such data should be written.
    ///
    /// If no output directory is specified, this property will use lazy initialization to create a
    /// directory in the `NSTemporaryDirectory()` with a subpath of the `taskRunUUID` and the current
    /// date.
    ///
    /// In general, set this property after instantiating the task view controller and before
    /// presenting it in order to override the default location.
    ///
    /// Before presenting the view controller, set the `outputDirectory` property to specify a
    /// path where files should be written when an `ORKFileResult` object must be returned for
    /// a step.
    ///
    /// - note: The calling application is responsible for deleting this directory once the files
    /// are processed by encrypting them locally. The encrypted files can then be stored for upload
    /// to a server or cloud service. These files are **not** encrypted so depending upon the
    /// application, there is a risk of exposing PII data stored in these files.
    public var outputDirectory: URL! {
        get {
            guard parentPath == nil
                else {
                    return parentPath!.outputDirectory
            }
            if _outputDirectory == nil {
                let tempDir = NSTemporaryDirectory()
                let dir = result.taskRunUUID.uuidString
                let path = (tempDir as NSString).appendingPathComponent(dir)
                if !FileManager.default.fileExists(atPath: path) {
                    do {
                        #if os(macOS)
                        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [:])
                        #else
                        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [ .protectionKey : FileProtectionType.completeUntilFirstUserAuthentication ])
                        #endif
                    } catch let error as NSError {
                        print ("Error creating file: \(error)")
                        return nil
                    }
                }
                _outputDirectory = URL(fileURLWithPath: path, isDirectory: true)
            }
            return _outputDirectory
        }
        set {
            _outputDirectory = newValue
        }
    }
    private var _outputDirectory: URL!
    
    /// Is this the first step in the task?
    public var isFirstStep: Bool {
        var taskPath: RSDTaskPath! = self
        repeat {
            if taskPath.result.stepHistory.count > 1 {
                return false
            }
            taskPath = taskPath.parentPath
        } while taskPath != nil
        return true
    }
    
    /// Initialize the task path with a task.
    /// - parameters:
    ///     - task: The task to set for this path segment.
    ///     - parentPath: A pointer to the parent task path. Default is `nil`.
    public init(task: RSDTask, parentPath: RSDTaskPath? = nil) {
        self.identifier = task.identifier
        self.task = task
        self.result = task.instantiateTaskResult()
        super.init()
        commonInit(identifier: task.identifier, parentPath: parentPath)
    }
    
    /// Initialize the task path with a task.
    /// - parameters:
    ///     - taskInfo: The task info to set for this path segment.
    ///     - parentPath: A pointer to the parent task path. Default is `nil`.
    public init(taskInfo: RSDTaskInfoStep, parentPath: RSDTaskPath? = nil) {
        self.identifier = taskInfo.identifier
        self.taskInfo = taskInfo
        self.result = RSDTaskResultObject(identifier: taskInfo.identifier)  // Create a temporary result
        super.init()
        commonInit(identifier: taskInfo.identifier, parentPath: parentPath)
    }
    
    private func commonInit(identifier: String, parentPath: RSDTaskPath?) {
        guard let parentPath = parentPath else { return }
        parentPath.childPaths[identifier] = self
        retainParent(parentPath)
        self.previousResults = (parentPath.result.stepHistory.rsd_last(where: { $0.identifier == identifier }) as? RSDTaskResult)?.stepHistory
        self.trackingDelegate = parentPath.trackingDelegate
        self.setupTracking()
    }
    
    /// Move up the parent chain by releasing the strong reference to the parent and returning it.
    internal func releaseParent() -> RSDTaskPath? {
        let parent = _strongParent
        _strongParent = nil
        return parent
    }
    
    internal func retainParent(_ newParent: RSDTaskPath) {
        self.parentPath = newParent
        _strongParent = newParent
    }
    
    internal func setupTracking() {
        guard let navigator = self.task?.stepNavigator as? RSDTrackingStepNavigator else { return }
        navigator.setupTracking(with: self)
    }
    
    /// Fetch the task associated with this path. This method loads the task and sets up the
    /// task result once finished.
    /// - parameters:
    ///     - factory: The factory to use to decode the task.
    ///     - completion: The callback handler to call when the task is loaded.
    public func fetchTask(with factory: RSDFactory, completion: @escaping FetchCompletionHandler) {
        guard !self.isLoading && self.task == nil else {
            debugPrint("\(self.description): Already loading task.")
            return
        }
        guard let taskInfo = self.taskInfo else {
            fatalError("Cannot fetch a task with a nil task info.")
        }
        
        self.isLoading = true
        taskInfo.taskTransformer.fetchTask(with: factory, taskIdentifier: self.identifier, schemaInfo: taskInfo.taskInfo.schemaInfo) { [weak self] (info, task, error) in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            if task != nil {
                strongSelf.task = task
                let previousResult = strongSelf.result
                strongSelf.result = task!.instantiateTaskResult()
                if previousResult.asyncResults?.count ?? 0 > 0 {
                    var results = strongSelf.result.asyncResults ?? []
                    results.append(contentsOf: previousResult.asyncResults!)
                    strongSelf.result.asyncResults = results
                }
                strongSelf.setupTracking()
            }
            completion(strongSelf, error)
        }
    }
    
    /// Append the result to the end of the step history, replacing the previous instance with the same
    /// identifier and adding the previous instance to the previous results.
    /// - parameter newResult:  The result to add to the step history.
    public func appendStepHistory(with newResult: RSDResult) {
        guard let previousResult = result.appendStepHistory(with: newResult) else { return }
        _appendPreviousResults(previousResult)
    }
    
    /// Remove results from the step history from the result with the given identifier to the end of the
    /// array. Add these results to the previous results set.
    /// - parameter stepIdentifier:  The identifier of the result associated with the given step.
    public func removeStepHistory(from stepIdentifier: String) {
        guard let previous = result.removeStepHistory(from: stepIdentifier) else { return }
        for previousResult in previous {
            _appendPreviousResults(previousResult)
        }
    }
    
    private func _appendPreviousResults(_ previousResult: RSDResult) {
        if previousResults == nil {
            previousResults = [previousResult]
        }
        else {
            if let idx = previousResults!.index(where: { $0.identifier == previousResult.identifier }) {
                previousResults!.remove(at: idx)
            }
            previousResults!.append(previousResult)
        }
    }
    
    /// Append the async results with the given result, replacing the previous instance with the same identifier.
    /// The step history is used to describe the path you took to get to where you are going, whereas
    /// the asynchronous results include any canonical results that are independent of path.
    /// - parameter result:  The result to add to the async results.
    public func appendAsyncResult(with newResult: RSDResult) {
        result.appendAsyncResult(with: newResult)
    }
    
    /// The description of the path.
    override public var description: String {
        return "\(type(of: self)): \(fullPath) steps: [\(stepPath)]"
    }
    
    // MARK: NSCopying
    
    private init(with identifier: String, result: RSDTaskResult, taskInfo: RSDTaskInfoStep?, task: RSDTask?) {
        guard taskInfo != nil || task != nil else {
            fatalError("Cannot initializa a task path with both a nil task info and nil task.")
        }
        self.identifier = identifier
        self.result = result
        self.taskInfo = taskInfo
        self.task = task
        super.init()
    }
    
    /// Implementation for copying a task path.
    public func copy(with zone: NSZone? = nil) -> Any {
        let result = (self.result as? NSCopying)?.copy(with: nil) as? RSDTaskResult ?? self.result
        let taskInfo = (self.taskInfo as? NSCopying)?.copy(with: nil) as? RSDTaskInfoStep ?? self.taskInfo
        let task = (self.task as? NSCopying)?.copy(with: nil) as? RSDTask ?? self.task
        
        let copy = type(of: self).init(with: self.identifier, result: result, taskInfo: taskInfo, task: task)
        copy.scheduleIdentifier = self.scheduleIdentifier
        copy.previousResults = self.previousResults?.map({ ($0 as? NSCopying)?.copy(with: nil) as? RSDResult ?? $0 })
        copy.parentPath = self.parentPath?.copy() as? RSDTaskPath
        copy.isCompleted = self.isCompleted
        return copy
    }
    
    
    // MARK: Task Finalization - The methods included in this section should **not** be called until the task is finished.
    
    /// A queue that can be used to serialize archiving and cleaning up the file output.
    public let fileManagementQueue = DispatchQueue(label: "org.sagebase.Research.fileQueue.\(UUID())")
    
    /// Convenience method for encoding a result. This is a work-around for a limitation of the encoder
    /// where it cannot encode an object without a Type for the object.
    /// - parameter encoder: The factory top-level encoder.
    /// - returns: The encoded result.
    public func encodeResult(to encoder: RSDFactoryEncoder) throws -> Data {
        return try self.result.rsd_encodeObject(to: encoder)
    }
        
    /// Delete the output directory on the file management queue. Do *not* call this method until the
    /// files generated by this task have been copied to a new location, unless the results are being
    /// discarded.
    public func deleteOutputDirectory(_ completion:(() -> Void)? = nil) {
        fileManagementQueue.async {
            
            guard let outputDirectory = self._outputDirectory else { return }
            do {
                try FileManager.default.removeItem(at: outputDirectory)
            } catch let error {
                print("Error removing output directory: \(error.localizedDescription)")
                debugPrint("\tat: \(outputDirectory)")
            }
            completion?()
        }
    }
    
    /// Build an archive from the task result.
    ///
    /// This method will recurse through the task result and pull out data for archiving using the given
    /// `RSDDataArchiveManager` to manage vending `RSDDataArchive` instances as appropriate. The completion
    /// handler will be called on the `fileManagementQueue` so that the app can manage any post-processing
    /// that must be serialized as appropriate.
    ///
    /// This method will call `RSDDataArchive.insertDataIntoArchive()` for each `RSDArchivable` result found
    /// in the collection.
    ///
    /// This method will insert the `RSDTaskResult` as JSON-encoded Data unless
    /// `RSDDataArchive.shouldInsertData(for: .taskResult) == false`
    ///
    /// Finally, it will recursively look through the task result step history and async results for
    /// `RSDAnswerResult` objects. The answer results will be added to a consolidated mapping dictionary of
    /// answers where the key = `\(section.identifier).\(result.identifier)` and the value is the `value`
    /// property. This dictionary will be serialized as JSON-encoded Data.
    ///
    /// The file results will be added to the files list in a JSON serialized file named "metadata.json"
    /// that includes information about the device, application, task, and a file manifest.
    ///
    public func archiveResults(with manager: RSDDataArchiveManager, completion: (() -> Void)? = nil) {
        fileManagementQueue.async {
            do {
                let taskArchiver = TaskArchiver(manager: manager, taskResult: self.result, scheduleIdentifier: self.scheduleIdentifier)
                let archives = try taskArchiver.buildArchives()
                manager.encryptAndUpload(taskPath: self, dataArchives: archives) {
                    self.deleteOutputDirectory(completion)
                }
            } catch let error {
                manager.handleArchiveFailure(taskPath: self, error: error) {
                    self.deleteOutputDirectory(completion)
                }
            }
        }
    }
}
