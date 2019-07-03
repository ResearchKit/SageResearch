//
//  RSDSampleRecorder.swift
//  Research
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// The `RSDSampleRecord` defines the properties that are included with all JSON logging samples.
/// By defining a protocol, the logger can include markers for step transitions and the records
/// are defined as `Codable` but the actual `CodingKey` implementation can be changed to match
/// the requirements of the research study.
public protocol RSDSampleRecord : Codable {
    
    /// An identifier marking the current step.
    ///
    /// This is a path marker where the path components are separated by a '/' character. This path includes
    /// the task identifier and any sections or subtasks for the full path to the current step.
    var stepPath: String { get }
    
    /// The date timestamp when the measurement was taken (if available). This should be included for the
    /// first entry to mark the start of the recording. Other than to mark step changes, the `timestampDate`
    /// is optional and should only be included if required by the research study.
    var timestampDate: Date? { get }
    
    /// A timestamp that is relative to the system uptime.
    ///
    /// This should be included for the first entry to mark the start of the recording. Other than to mark
    /// step changes, the `timestamp` is optional and should only be included if required by the research
    /// study.
    ///
    /// On Apple devices, this is the timestamp used to mark sensors that run in the foreground only such as
    /// video processing and motion sensors.
    ///
    /// syoung 04/24/2019 Per request from Sage Bionetworks' research scientists, this timestamp is "zeroed"
    /// to when the recorder is started. It should be calculated by offsetting the
    /// `ProcessInfo.processInfo.systemUptime` from the monotonic clock time to account for gaps in the
    /// sampling due to the application becoming inactive. For example, if the participant accepts a phone
    /// call while the recorder is running.
    ///
    /// -seealso: `ProcessInfo.processInfo.systemUptime`
    var timestamp: TimeInterval? { get }
}

extension RSDSampleRecord {
    
    /// All sample records should include either `timestampDate` or `timestamp`.
    func validate() throws {
        guard (timestampDate != nil) || (timestamp != nil) else {
            let message = "Expected either timestamp or timestampDate to be non-nil"
            assertionFailure(message)
            throw RSDValidationError.unexpectedNullObject(message)
        }
    }
}

/// `RSDRecordMarker` is a concrete implementation of `RSDSampleRecord` that can be used to mark the step transitions
/// for a recording.
public struct RSDRecordMarker : RSDSampleRecord {
    
    /// The clock uptime. On Apple OS platforms, this is the time interval since the device was rebooted or
    /// the clock rolled.
    ///
    /// - seealso: `RSDClock.uptime()`
    public let uptime: TimeInterval
    
    /// An identifier marking the current step.
    public let stepPath: String
    
    /// The date timestamp when the measurement was taken (if available).
    public let timestampDate: Date?
    
    /// The relative timestamp used by this recorder.
    ///
    /// -seealso: `ProcessInfo.processInfo.systemUptime`
    public let timestamp: TimeInterval?
    
    /// Default initializer.
    /// - parameters:
    ///     - uptime: The clock uptime.
    ///     - stepPath: An identifier marking the current step.
    ///     - timestampDate: The date timestamp when the measurement was taken (if available).
    ///     - timestamp: Relative time to when the recorder was started.
    public init(uptime: TimeInterval, timestamp: TimeInterval, date: Date, stepPath: String) {
        self.uptime = uptime
        self.timestamp = timestamp
        self.stepPath = stepPath
        self.timestampDate = date
    }
    
    /// MARK: `Codable` protocol implementation
    ///
    /// - example:
    ///
    ///     ```
    ///        {
    ///            "uptime": 1234.56,
    ///            "stepPath": "/Foo Task/sectionA/step1",
    ///            "timestampDate": "2017-10-16T22:28:09.000-07:00",
    ///            "timestamp": 0
    ///        }
    ///     ```
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case uptime, stepPath, timestampDate, timestamp
    }
}

/// `RSDSampleRecorder` is a base-class implementation of a controller that is used to record samples.
///
/// While it isn't prohibited to instantiate this class directly, this is *intended* as an abstract implementation
/// for recording sample data from GPS location, accelerometers, etc.
///
/// Using this base implementation allows for a consistent logging of shared sample data key words for the step path
/// and the uptime. It implements the logic for writing to a file, tracking the uptime and start date, and provides
/// a consistent implementation for error handling.
open class RSDSampleRecorder : NSObject, RSDAsyncAction {

    /// Errors returned in the completion handler during `start()` when starting fails for timing reasons.
    public enum RecorderError : Error {
        
        /// Returned when the recorder has already been started.
        case alreadyRunning
        
        /// Returned when the recorder that has been cancelled, failed, or finished.
        case finished
        
        /// Returned when the recorder or task was interrupted.
        case interrupted
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - configuration: The configuration used to set up the controller.
    ///     - taskViewModel:
    ///     - outputDirectory: File URL for the directory in which to store generated data files.
    public init(configuration: RSDAsyncActionConfiguration, taskViewModel: RSDPathComponent, outputDirectory: URL) {
        self.configuration = configuration
        self.taskViewModel = taskViewModel
        self.outputDirectory = outputDirectory
        self.collectionResult = RSDCollectionResultObject(identifier: configuration.identifier)
    }
    
    // Mark: `RSDAsyncAction` implementation
    
    /// Delegate callback for handling action completed or failed.
    open weak var delegate: RSDAsyncActionDelegate?
    
    /// The configuration used to set up the controller.
    public let configuration: RSDAsyncActionConfiguration
    
    /// The associated task path to which the result should be attached.
    public let taskViewModel: RSDPathComponent
    
    /// The status of the recorder.
    ///
    /// - note: This property is implemented as `@objc dynamic` so that step view controllers can use KVO
    ///         to listen for changes.
    @objc dynamic public private(set) var status: RSDAsyncActionStatus = .idle
    
    /// Is the action currently paused?
    ///
    /// - note: This property is implemented as `@objc dynamic` so that step view controllers can use KVO
    ///         to listen for changes.
    @objc dynamic open private(set) var isPaused: Bool = false
    
    /// The last error on the action controller.
    /// - note: Under certain circumstances, getting an error will not result in a terminal failure of the controller.
    /// For example, if a controller is both processing motion and camera sensors and only the motion sensors failed
    /// but using them is a secondary action.
    public var error: Error?
    
    /// Results for this recorder.
    ///
    /// During initialization the recorder will instantiate an `RSDCollectionResult` that can be used
    /// to collect any results attached to this recorder, including the `ORKFileResult` that points to
    /// the logging file used to record the log samples. This property will only return a non-nil result
    /// if the collection includes one or more results. If there is only one result, then that one result
    /// is returned. Otherwise, the `collectionResult` is returned.
    ///
    /// - seealso: `collectionResult`
    public var result: RSDResult? {
        guard collectionResult.inputResults.count > 0 else { return nil }
        if collectionResult.inputResults.count == 1 {
            return collectionResult.inputResults.first
        } else {
            return collectionResult
        }
    }
    
    /// Start the recorder with the given completion handler.
    ///
    /// This method is called by the task controller to start the recorder. This implementation performs the
    /// following actions:
    /// 1. Check to see if the recorder is already running or has been cancelled and will call the completion
    ///     handler with an error if that is the case.
    /// 2. Update the `startUptime` and `startDate` to the current time.
    /// 3. Open a file for logging samples.
    /// 4. If and only if the logging file was successfully opened, then call `startRecorder()` asynchronously
    ///     on the main queue.
    ///
    /// - note: This is implemented as a `public final` class to block overriding this method. Instead,
    /// subclasses should implement logic required to start a recorder by overriding the `startRecorder()`
    /// method. This is done to ensure that the logging file was successfully created before attempting to
    /// record any data to that file.
    public final func start(_ completion: RSDAsyncActionCompletionHandler?) {

        guard self.status < RSDAsyncActionStatus.finished else {
            self.callOnMainThread(nil, RecorderError.finished, completion)
            return
        }
        
        guard self.status <= .permissionGranted else {
            self.callOnMainThread(nil, RecorderError.alreadyRunning, completion)
            return
        }
        
        // Set paused to false and set the start uptime and timestamp
        isPaused = false
        clock = RSDClock()
        _syncUpdateStatus(.starting)
        
        self.loggerQueue.async {
            do {
                try self._startLogger(at: self.taskViewModel)
                DispatchQueue.main.async {
                    guard self.status < RSDAsyncActionStatus.finished else {
                        completion?(self, nil, RecorderError.finished)
                        return
                    }
                    self.startRecorder({ (newStatus, error) in
                        self._syncUpdateStatus(newStatus, error: error)
                        self.callOnMainThread(self.result, error ?? self.error, completion)
                    })
                }
            } catch let error {
                self.callOnMainThread(nil, error, completion)
            }
        }
    }
    
    /// Pause the action. The base class implementation marks the `isPaused` property as `true`.
    open func pause() {
        isPaused = true
    }
    
    /// Resume the action. The base class implementation marks the `isPaused` property as `false`.
    open func resume() {
        isPaused = false
    }
    
    /// Stop the action with the given completion handler.
    ///
    /// This method is called by the task controller to stop the recorder. This implementation will first
    /// close the logging file and then call `stopRecorder()` asynchronously on the main queue. The
    /// `stopRecorder()` method is called whether or not there is an error when closing the logging file
    /// so that subclasses can perform any required cleanup.
    ///
    /// - note: This is implemented as a `public final` class to block overriding this method. Instead,
    /// subclasses should implement logic required to stop a recorder by overriding the `stopRecorder()`
    /// method. This is done to ensure that the logging file is closed and the result is added to the result
    /// collection *before* handing over control to the subclass.
    ///
    public final func stop(_ completion: RSDAsyncActionCompletionHandler?) {
        _syncUpdateStatus(.waitingToStop)
        self.loggerQueue.async {
            do {
                self._syncUpdateStatus(.processingResults)
                try self._stopLogger()
            } catch let err {
                self.error = err
            }
            DispatchQueue.main.async {
                self.stopRecorder({ (newStatus) in
                    if newStatus > self.status {
                        self._syncUpdateStatus(newStatus)
                    } else {
                        self._syncUpdateStatus(.finished)
                    }
                    self.callOnMainThread(self.result, self.error, completion)
                })
            }
        }
    }
    
    /// Cancel the action. The default implementation will set the `isCancelled` flag to `true` and then
    /// call `stop()` with a nil completion handler.
    open func cancel() {
        _syncUpdateStatus(.cancelled)
        stop()
    }
    
    /// Let the controller know that the task has moved to the given step. This method is called by the task
    /// controller when the task transitions to a new step. The default implementation will update the
    /// `currentStepIdentifier` and `currentStepPath`, then it will add a marker to the logging files.
    open func moveTo(step: RSDStep, taskViewModel: RSDPathComponent) {
        _writeMarkers(step: step, taskViewModel: taskViewModel)
    }
    
    #if os(watchOS)
    /// **Available** for watchOS.
    ///
    /// This method should be called on the main thread with the completion handler also called on the main
    /// thread. The base class implementation will immediately call the completion handler.
    ///
    /// - remark: Override to implement custom permission handling.
    /// - seealso: `RSDAsyncAction.requestPermissions()`
    /// - parameters:
    ///     - completion: The completion handler.
    open func requestPermissions(_ completion: @escaping RSDAsyncActionCompletionHandler) {
        _syncUpdateStatus(.permissionGranted)
        completion(self, self.result, nil)
    }
    
    #elseif os(macOS)
    /// **Available** for macOS.
    ///
    /// This method should be called on the main thread with the completion handler also called on the main
    /// thread. The base class implementation will immediately call the completion handler.
    ///
    /// - remark: Override to implement custom permission handling.
    /// - seealso: `RSDAsyncAction.requestPermissions(on:)`
    /// - parameters:
    ///     - viewController: The view controler that should be used to present any modal dialogs.
    ///     - completion: The completion handler.
    open func requestPermissions(on viewController: NSViewController, _ completion: @escaping RSDAsyncActionCompletionHandler) {
        _syncUpdateStatus(.permissionGranted)
        completion(self, self.result, nil)
    }
    
    
    #else
    /// **Available** for iOS and tvOS.
    ///
    /// This method should be called on the main thread with the completion handler also called on the main
    /// thread. The base class implementation will immediately call the completion handler.
    ///
    /// - remark: Override to implement custom permission handling.
    /// - seealso: `RSDAsyncAction.requestPermissions(on:)`
    /// - parameters:
    ///     - viewController: The view controler that should be used to present any modal dialogs.
    ///     - completion: The completion handler.
    open func requestPermissions(on viewController: UIViewController, _ completion: @escaping RSDAsyncActionCompletionHandler) {
        _syncUpdateStatus(.permissionGranted)
        completion(self, self.result, nil)
    }
    #endif
    
    // MARK: State management
    
    /// Is this recorder running in the simulator?
    public let isSimulator: Bool = {
        #if (arch(i386) || arch(x86_64)) && !os(OSX)
            return true
        #else
            return false
        #endif
    }()

    /// The collection result is used internally to allow storing multiple results associated with this recorder.
    /// For example, a location recorder may also query the pedometer and record the number of steps during a
    /// walking or runnning task.
    ///
    /// During initialization the recorder will instantiate an `RSDCollectionResultObject` that can be used
    /// to collect any results attached to this recorder, including the `ORKFileResult` that points to
    /// the logging file used to record the log samples. The property is marked as `open` to allow subclasses
    /// to point at a different implementation of the `RSDCollectionResult` protocol.
    open private(set) var collectionResult: RSDCollectionResult
    
    /// The clock for this recorder.
    open private(set) var clock: RSDClock = RSDClock()
    
    /// The date timestamp for when the recorder was started.
    public var startDate: Date {
        return clock.startDate
    }
    
    /// The identifier for tracking the current step.
    public private(set) var currentStepIdentifier: String = ""
    
    /// The current `stepPath` to record to log samples.
    public private(set) var currentStepPath: String = ""
    
    /// A conveniece method for calling the result handler on the main thread asynchronously.
    private func callOnMainThread(_ result: RSDResult?, _ error: Error?, _ completion: RSDAsyncActionCompletionHandler?) {
        DispatchQueue.main.async {
            completion?(self, result, error)
        }
    }
    
    /// This method is called during startup after the logger is setup to start the recorder. The base class
    /// implementation will immediately call the completion handler. If an overriding class needs to do any
    /// initialization to start the recorder, then override this method. If the override calls the completion
    /// handler then **DO NOT** call super. This method is called from `start()` on the main thread queue.
    ///
    /// - parameter completion: Callback for updating the status of the recorder once startup has completed
    ///                         (or failed).
    open func startRecorder(_ completion: @escaping ((RSDAsyncActionStatus, Error?) -> Void)) {
        completion(.running, nil)
    }

    /// Convenience method for stopping the recorder without a callback handler.
    public final func stop() {
        stop(nil)
    }

    /// This method is called during finish after the logger is closed. The base class implementation will
    /// immediately call the completion handler. If an overriding class needs to do any actions to stop the
    /// recorder, then override this method. If the override calls the completion handler then **DO NOT**
    /// call super. Otherwise, super will call the completion with the logger error as the input to the
    /// completion handler. This method is called from `stop()` on the main thread queue.
    ///
    /// - parameter completion: Callback for updating the status of the recorder once startup has completed
    ///                         (or failed).
    open func stopRecorder(_ completion: @escaping ((RSDAsyncActionStatus) -> Void)) {
        completion(.finished)
    }
    
    /// This method can be called by either the logging file if there was a write error, or by the subclass
    /// if there was an error when attempting to record samples. The method will call the delegate method
    /// `asyncAction(_, didFailWith:)` asynchronously on the main queue and will call `cancel()`
    /// synchronously on the current queue.
    open func didFail(with error: Error) {
        guard self.status <= .running else { return }
        _syncUpdateStatus(.failed, error: error)
        DispatchQueue.main.async {
            self.delegate?.asyncAction(self, didFailWith: error)
        }
        cancel()
    }

    /// Append the `collectionResult` with the given result.
    /// - parameter result: The result to add to the collection.
    public final func appendResults(_ result: RSDResult) {
        guard self.status <= RSDAsyncActionStatus.processingResults else {
            debugPrint("WARNING: Attempting to append the result set after status has been locked. \(self.status)")
            return
        }
        self.collectionResult.appendInputResults(with: result)
    }
    
    /// This method will synchronously update the status and is expected to **only** be called by a subclass to allow
    /// subclasses to transition the status from `.processingResults` to `.stopping` and then `.finished` or from
    /// `.starting` to `.running`.
    public final func updateStatus(to newStatus: RSDAsyncActionStatus, error: Error?) {
        _syncUpdateStatus(newStatus, error: error)
    }
    
    /// Synchronously update the status. If called from a background thread, then this call will block until
    /// the main thread is available. The status is only changed on the main thread to ensure that KVO observers
    /// are on the main thread and also to ensure that the status is changed synchronously.
    private func _syncUpdateStatus(_ newStatus: RSDAsyncActionStatus, error: Error? = nil) {
        // Status transitions are sequential so do not change the status if the new status is not greater than
        // the current status
        guard newStatus > self.status else { return }
        
        // Check if this is the main thread and if not, then call it *synchronously* on the main thread.
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                self._syncUpdateStatus(newStatus, error: error)
            }
            return
        }
        
        // Change the status
        self.status = newStatus
        self.error = error
    }
    
    // MARK: Logger handling
    
    /// The serial queue used for writing samples to the log files. To ensure that write failures due to memory
    /// warnings do not get thrown by multiple threads, a single logging queue is used for writing to all the
    /// open log files.
    public let loggerQueue = DispatchQueue(label: "org.sagebase.Research.Recorder.\(UUID())")
    
    /// The loggers used to record samples to a file.
    public private(set) var loggers: [String : RSDDataLogger] = [:]
    
    /// The list of identifiers for the loggers. For each unique identifier in this list, the recorder
    /// will open a file for recording record samples. This allows a single recorder to handle data from
    /// multiple sensors.
    ///
    /// For example, if the application requires recording both raw accelerometer data and the device
    /// motion data, these can be recordeded to different sample files by defining a unique identifier
    /// for each sensor recording, while using a single `CMMotionManager` as recommended by Apple.
    open var loggerIdentifiers : Set<String> {
        return [defaultLoggerIdentifier]
    }
    
    /// The default logger identifier to call if the `writeSample()` method is called without a logger
    /// identifier.
    open var defaultLoggerIdentifier : String {
        return "\(sectionIdentifier)\(configuration.identifier)"
    }
    
    /// The section identifier for this recorder.
    /// An identifier string that can be appended to a step view controller to differentiate this step from
    /// another instance in a different section.
    open var sectionIdentifier: String {
        return (self.taskViewModel.parent != nil) ? "\(self.taskViewModel.taskResult.identifier)_" : ""
    }
    
    /// File URL for the directory in which to store generated data files.
    public let outputDirectory: URL
    
    /// Should the logger use a dictionary as the root element?
    ///
    /// If `true` then the logger will open the file with the samples included in an array with the key
    /// of "items". If `false` then the file will use an array as the root elemenent and the samples will
    /// be added to that array.
    open var usesRootDictionary: Bool {
        return (self.configuration as? RSDJSONRecorderConfiguration)?.usesRootDictionary ?? false
    }
    
    /// instantiate a marker for recording step transitions as well as start and stop points.
    /// The default implementation will instantiate a `RSDRecordMarker`.
    ///
    /// - parameters:
    ///     - uptime: The system clock time.
    ///     - timestamp: Relative timestamp for this recorder.
    ///     - date: The timestamp date.
    ///     - stepPath: The step path.
    ///     - loggerIdentifier: The identifier for the logger for which to create the marker.
    /// - returns: A sample to add to the log file that can be used as a step transition marker.
    open func instantiateMarker(uptime: TimeInterval, timestamp: TimeInterval, date: Date, stepPath: String, loggerIdentifier:String) -> RSDSampleRecord {
        return RSDRecordMarker(uptime: uptime, timestamp: timestamp, date: date, stepPath: stepPath)
    }
    
    /// Update the current step and step path.
    ///
    /// - parameters:
    ///     - step: The current step.
    ///     - taskViewModel: The current path.
    open func updateMarker(step: RSDStep?, taskViewModel: RSDPathComponent) {
        currentStepIdentifier = step?.identifier ?? ""
        let path = taskViewModel.fullPath
        currentStepPath = (path as NSString).appendingPathComponent(currentStepIdentifier)
    }
    
    /// Write a sample to the logger.
    /// - parameters:
    ///     - sample: sample: The sample to add to the logging file.
    ///     - loggerIdentifier: The identifier for the logger for which to create the marker. If nil, then the
    ///                         `defaultLoggerIdentifier` will be used.
    public final func writeSample(_ sample: RSDSampleRecord, loggerIdentifier:String? = nil) {
        self.loggerQueue.async {
            // Only write to the file if the recorder status indicates that the logging file is open
            guard self.status >= RSDAsyncActionStatus.starting && self.status <= RSDAsyncActionStatus.running else { return }
            
            let identifier = loggerIdentifier ?? self.defaultLoggerIdentifier
            guard let logger = self.loggers[identifier] as? RSDRecordSampleLogger else { return }
            do {
                try logger.writeSample(sample)
            } catch let err {
                DispatchQueue.global().async {
                    self.didFail(with: err)
                }
            }
        }
    }
    
    /// Write multiple samples to the logger.
    /// - parameters:
    ///     - samples: The samples to add to the logging file.
    ///     - loggerIdentifier: The identifier for the logger for which to create the marker. If nil, then the
    ///                         `defaultLoggerIdentifier` will be used.
    public final func writeSamples(_ samples: [RSDSampleRecord], loggerIdentifier:String? = nil) {
        self.loggerQueue.async {
            // Only write to the file if the recorder status indicates that the logging file is open
            guard self.status >= RSDAsyncActionStatus.starting && self.status <= RSDAsyncActionStatus.running else { return }
        
            // Check that the logger hasn't been closed and nil'd
            let identifier = loggerIdentifier ?? self.defaultLoggerIdentifier
            guard let logger = self.loggers[identifier] as? RSDRecordSampleLogger else { return }
            do {
                try logger.writeSamples(samples)
            } catch let err {
                DispatchQueue.global().async {
                    self.didFail(with: err)
                }
            }
        }
    }
    
    /// Instantiate the logger file for the given identifier.
    ///
    /// By default, the file will be created using the `RSDFileResultUtility.createFileURL()` utility method
    /// to create a URL in the `outputDirectory`. A `RSDRecordSampleLogger` is returned by default.
    ///
    /// - parameter identifier: The unique identifier for the logger.
    /// - returns: A new instance of a `RSDDataLogger`.
    /// - throws: An error if opening the log file failed.
    open func instantiateLogger(with identifier: String) throws -> RSDDataLogger? {
        let format = stringEncodingFormat()
        let ext = format?.fileExtension ?? "json"
        let shouldDelete = (self.configuration as? RSDRestartableRecorderConfiguration)?.shouldDeletePrevious ?? false
        let url = try RSDFileResultUtility.createFileURL(identifier: identifier, ext: ext, outputDirectory: outputDirectory, shouldDeletePrevious: shouldDelete)
        return try RSDRecordSampleLogger(identifier: identifier, url: url, usesRootDictionary: self.usesRootDictionary, stringEncodingFormat: format)
    }
    
    /// Returns the string encoding format to use for this file. Default is `nil`. If this is `nil`
    /// then the file will be formatted using JSON encoding.
    open func stringEncodingFormat() -> RSDStringSeparatedEncodingFormat? {
        return nil
    }
    
    /// Write a marker to each logging file.
    private func _writeMarkers(step: RSDStep?, taskViewModel: RSDPathComponent) {
        let uptime = RSDClock.uptime()
        let timestamp = clock.zeroRelativeTime(to: ProcessInfo.processInfo.systemUptime)
        let date = Date()
        self.loggerQueue.async {
            
            // Update the marker
            self.updateMarker(step: step, taskViewModel: taskViewModel)
            let stepPath = self.currentStepPath
            
            // Only write to the file if the recorder status indicates that the logging file is open
            guard self.status >= RSDAsyncActionStatus.starting && self.status <= RSDAsyncActionStatus.running else { return }
            
            do {
                for (identifier, dataLogger) in self.loggers {
                    guard let logger = dataLogger as? RSDRecordSampleLogger else { continue }
                    let marker = self.instantiateMarker(uptime: uptime, timestamp: timestamp, date: date, stepPath: stepPath, loggerIdentifier: identifier)
                    try logger.writeSample(marker)
                }
            } catch let err {
                DispatchQueue.global().async {
                    self.didFail(with: err)
                }
            }
        }
    }
    
    /// Open log files. This method should be called on the `loggerQueue`.
    private func _startLogger(at taskViewModel: RSDPathComponent) throws {
        let step = taskViewModel.currentNode?.step
        updateMarker(step: step, taskViewModel: taskViewModel)
        for identifier in self.loggerIdentifiers {
            guard let dataLogger = try instantiateLogger(with: identifier) else {
                continue
            }
            loggers[identifier] = dataLogger
            if let logger = dataLogger as? RSDRecordSampleLogger {
                let marker = instantiateMarker(uptime: self.clock.startUptime, timestamp: 0, date: self.clock.startDate, stepPath: currentStepPath, loggerIdentifier: identifier)
                try logger.writeSample(marker)
            }
        }
    }
    
    /// Close log files. This method should be called on the `loggerQueue`.
    private func _stopLogger() throws {
        var error: Error?
        for (_, logger) in self.loggers {
            do {
                try logger.close()
                
                // Create and add the result
                var fileResult = RSDFileResultObject(identifier: self.configuration.identifier)
                fileResult.startDate = self.startDate
                fileResult.endDate = Date()
                fileResult.url = logger.url
                fileResult.startUptime = self.clock.startSystemUptime
                fileResult.contentType = logger.contentType
                self.appendResults(fileResult)
            }
            catch let err {
                error = err
            }
        }
        
        // Close all the loggers
        loggers = [:]
        
        // throw the last caught error if there was one
        if error != nil {
            throw error!
        }
    }
}

/// A protocol that can be used to define the keys and header to use in a string-separated file.
/// - seealso: `RSDRecordSampleLogger`
public protocol RSDStringSeparatedEncodingFormat {
    
    /// The string to use as the separator. For example, a comma-delimited file uses a "," character.
    var encodingSeparator: String { get }
    
    /// The content type for the file.
    var contentType: String { get }
    
    /// The file extension for this file type.
    var fileExtension: String { get }
    
    /// A string that includes a header for the file. The columns in the table should be separated using
    /// the `encodingSeparator`.
    func fileTableHeader() -> String
    
    /// A list of the coding keys to use to build the delimited string for a single Element in an Array.
    func codingKeys() -> [CodingKey]
}

/// Implementation of the `RSDStringSeparatedEncodingFormat` protocol that wraps a comma separated encodable.
public struct CSVEncodingFormat<K> : RSDStringSeparatedEncodingFormat where K : RSDDelimiterSeparatedEncodable {
    public typealias Key = K
    
    /// Does this encoding format include a header?
    public var includesHeader: Bool = true
    
    /// Returns a comma.
    public var encodingSeparator: String {
        return ","
    }
    
    /// Returns "text/csv".
    public var contentType: String {
        return "text/csv"
    }
    
    /// Returns "csv".
    public var fileExtension: String {
        return "csv"
    }
    
    public func fileTableHeader() -> String {
        return includesHeader ? Key.fileTableHeader(with: encodingSeparator) : ""
    }
    
    public func codingKeys() -> [CodingKey] {
        return Key.codingKeys()
    }
    
    public init() {
    }
}

/// `RSDRecordSampleLogger` is used to write samples encoded as json dictionary objects to a logging file.
public class RSDRecordSampleLogger : RSDDataLogger {
    
    /// Errors that can be thrown by the logger.
    public enum RSDRecordSampleLoggerError : Error {
        /// The logger failed to encode a string.
        case stringEncodingFailed(String)
    }
    
    /// Is the root element in the json file a dictionary?
    /// - seealso: `RSDSampleRecorder.usesRootDictionary`
    public let usesRootDictionary: Bool
    
    /// Does the recorder use a string-delimited format for saving each sample? If so, this contains the keys
    /// used to support encoding in that format.
    public let stringEncodingFormat: RSDStringSeparatedEncodingFormat?
    
    /// Returns "application/json" or the string encoding if applicable.
    override public var contentType: String? {
        return stringEncodingFormat?.contentType ?? "application/json"
    }
    
    private let startText: String
    
    /// Default initializer. The initializer will automatically open the file and write the
    /// JSON root element and start the sample array.
    ///
    /// - parameters:
    ///     - identifier: A unique identifier for the logger.
    ///     - url: The url to the file.
    ///     - usesRootDictionary: Is the root element in the json file a dictionary?
    public init(identifier: String, url: URL, usesRootDictionary: Bool, stringEncodingFormat: RSDStringSeparatedEncodingFormat? = nil) throws {
        self.usesRootDictionary = usesRootDictionary
        self.stringEncodingFormat = stringEncodingFormat
        
        let startText: String
        if let format = stringEncodingFormat {
            startText = "\(format.fileTableHeader())"
        } else if usesRootDictionary {
            // If this json file uses a dictionary as its root, then add a start date timestamp
            // and a key for the items in the dictionary.
            let timestamp = RSDFactory.shared.encodeString(from: Date(), codingPath: [])
            startText =
            """
            {
            "startDate" : "\(timestamp)",
            "items"     : [
            """
        } else {
            // Otherwise, just open the array
            startText = "[\n"
        }
        guard let data = startText.data(using: .utf8) else {
            throw RSDRecordSampleLoggerError.stringEncodingFailed(startText)
        }
        self.startText = startText
        
        try super.init(identifier: identifier, url: url, initialData: data)
    }
    
    /// Write multiple samples to the logger.
    /// - parameter samples: The samples to add to the logging file.
    /// - throws: Error if writing the samples fails because the wasn't enough memory on the device.
    public func writeSamples(_ samples: [RSDSampleRecord]) throws {
        for sample in samples {
            try writeSample(sample)
        }
    }
    
    /// Write a sample to the logger.
    /// - parameter sample: The sample to add to the logging file.
    /// - throws: Error if writing the sample fails because the wasn't enough memory on the device.
    public func writeSample(_ sample: RSDSampleRecord) throws {
        if let format = self.stringEncodingFormat {
            let string = try sample.rsd_delimiterEncodedString(with: format.codingKeys(), delimiter: format.encodingSeparator)
            if sampleCount > 0 || startText.count > 0 {
                try write("\n\(string)")
            } else {
                try write("\(string)")
            }
        }
        else {
            if sampleCount > 0 {
                // If this is not the first sample then write a comma and line feed
                try write(",\n")
            }
            let data = try sample.rsd_jsonEncodedData()
            try write(data)
        }
    }
    
    /// Close the file. This will write the end tag for the root element and then close the file handle.
    /// If there is an error thrown by writing the closing tag, then the file handle will be closed and
    /// the error will be rethrown.
    ///
    /// - throws: Error thrown when attempting to write the closing tag.
    public override func close() throws {
        
        /// If there is a string encoding format, then there isn't a need for a JSON closure.
        guard self.stringEncodingFormat == nil else {
            try super.close()
            return
        }
        
        // Write the json closure to the file
        let endText = usesRootDictionary ? "\n]\n}" : "\n]"
        var writeError: Error?
        do {
            try write(endText)
        } catch let err {
            writeError = err
        }
        try super.close()
        // If there was an error writing the closure, then rethrow that error *after* closing the file
        if let error = writeError {
            throw error
        }
    }
    
    private func write(_ string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw RSDRecordSampleLoggerError.stringEncodingFailed(string)
        }
        try write(data)
    }
}

// TODO: syoung 09/27/2019 Look into whether or not there is a simple way to use the Documentable protocols in other frameworks.
extension RSDRecordMarker { //} : RSDDocumentableCodableObject {

    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    static func examples() -> [Encodable] {
        let date = rsd_ISO8601TimestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!
        return [RSDRecordMarker(uptime: 12344.56, timestamp: 0, date: date, stepPath: "/Foo Task/sectionA/step1")]
    }
}

