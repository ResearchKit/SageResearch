//
//  RSDSampleRecorder.swift
//  ResearchSuite
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

import Foundation

/// The `RSDSampleRecord` defines the properties that are included with all JSON logging samples.
/// By defining a protocol, the logger can include markers for step transitions and the records
/// are defined as `Codable` but the actual `CodingKey` implementation can be changed to match
/// the requirements of the research study.
public protocol RSDSampleRecord : Codable {
    
    /// The clock uptime. On Apple OS platforms, this is the time interval since the computer clock was rolled or started.
    ///
    /// This is included to allow the results from different files to be cross-referenced (for a given run of a task)
    /// using a shared time stamp.
    ///
    /// - seealso: `ProcessInfo.processInfo.systemUptime`.
    var uptime: TimeInterval { get }
    
    /// An identifier marking the current step.
    ///
    /// This is a path marker where the path components are separated by a '/' character. This path includes the task
    /// identifier and any sections or subtasks for the full path to the current step.
    var stepPath: String { get }
    
    /// The date timestamp when the measurement was taken (if available). This should be included for the first entry to
    /// mark the start of the recording. Other than to mark step changes, the `timestampDate` is optional and should only
    /// be included if required by the research study.
    var timestampDate: Date? { get }
    
    /// Relative time to when the recorder was started. This is included for compatibility to existing research studies
    /// that expect the timestamp to be a time interval since the start of the recording.
    var timestamp: TimeInterval? { get }
}

/// `RSDRecordMarker` is a concrete implementation of `RSDSampleRecord` that can be used to mark the step transitions
/// for a recording.
public struct RSDRecordMarker : RSDSampleRecord {
    
    /// The clock uptime.
    public let uptime: TimeInterval
    
    /// An identifier marking the current step.
    public let stepPath: String
    
    /// The date timestamp when the measurement was taken (if available).
    public let timestampDate: Date?
    
    /// Relative time to when the recorder was started.
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
    private enum CodingKeys : String, CodingKey {
        case uptime, stepPath, timestampDate, timestamp
    }
}

/// `RSDSampleRecorder` is a base-class implementation of a controller that is used to record samples.
///
/// While it isn't prohibited to instatiate this class directly, this is *intended* as an abstract implementation
/// for recording sample data from GPS location, accelerometers, etc.
///
/// Using this base implementation allows for a consistent logging of shared sample data key words for the step path
/// and the uptime. It implements the logic for writing to a file, tracking the uptime and start date, and provides
/// a consistent implementation for error handling.
open class RSDSampleRecorder : NSObject, RSDAsyncActionController {

    /// Errors returned in the completion handler during `start()` when starting fails for timing reasons.
    public enum RSDRecorderError : Error {
        
        /// Returned when the recorder has already been started.
        case alreadyRunning
        
        /// Returned when the recorder that has been cancelled.
        case cancelled
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - configuration: The configuration used to set up the controller.
    ///     - outputDirectory: File URL for the directory in which to store generated data files.
    public init(configuration: RSDAsyncActionConfiguration, outputDirectory: URL) {
        self.configuration = configuration
        self.outputDirectory = outputDirectory
        self.collectionResult = RSDCollectionResultObject(identifier: configuration.identifier)
    }
    
    // Mark: `RSDAsyncActionController` implementation
    
    /// Delegate callback for handling action completed or failed.
    open weak var delegate: RSDAsyncActionControllerDelegate?
    
    /// The configuration used to set up the controller.
    public let configuration: RSDAsyncActionConfiguration
    
    /// Is the action currently running? The base class implementation returns `true` if the logging file is open.
    ///
    /// - note: This property is implemented as `@objc dynamic` so that step view controllers can use KVO
    ///         to listen for changes.
    @objc dynamic open var isRunning: Bool {
        return loggers.count > 0
    }
    
    /// Is the action currently paused?
    ///
    /// - note: This property is implemented as `@objc dynamic` so that step view controllers can use KVO
    ///         to listen for changes.
    @objc dynamic open private(set) var isPaused: Bool = false
    
    /// Was the action cancelled?
    ///
    /// - note: This property is implemented as `@objc dynamic` so that step view controllers can use KVO
    ///         to listen for changes.
    @objc dynamic open private(set) var isCancelled: Bool = false
    
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
    public final func start(at taskPath: RSDTaskPath, completion: RSDAsyncActionCompletionHandler?) {
        guard !self.isRunning else {
            self.callOnMainThread(nil, RSDRecorderError.alreadyRunning, completion)
            return
        }
        guard !self.isCancelled else {
            self.callOnMainThread(nil, RSDRecorderError.cancelled, completion)
            return
        }
        
        // Set paused to false and set the start uptime and timestamp
        isPaused = false
        startUptime = ProcessInfo.processInfo.systemUptime
        startDate = Date()
        
        self.loggerQueue.async {
            do {
                try self._startLogger(at: taskPath)
                DispatchQueue.main.async {
                    if !self.isCancelled {
                        self.startRecorder(completion)
                    } else {
                        completion?(self, nil, RSDRecorderError.cancelled)
                    }
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
    public final func stop(_ completion: RSDAsyncActionCompletionHandler?) {
        self.loggerQueue.async {
            var error: Error?
            do {
                try self._stopLogger()
            } catch let err {
                error = err
            }
            DispatchQueue.main.async {
                self.stopRecorder(loggerError: error, completion)
            }
        }
    }
    
    /// Cancel the action. The default implementation will set the `isCancelled` flag to `true` and then
    /// call `stop()` with a nil completion handler.
    open func cancel() {
        isCancelled = true
        stop()
    }
    
    /// Let the controller know that the task has moved to the given step. This method is called by the task
    /// controller when the task transitions to a new step. The default implementation will update the
    /// `currentStepIdentifier` and `currentStepPath`, then it will add a marker to the logging files.
    open func moveTo(step: RSDStep, taskPath: RSDTaskPath) {
        updateMarker(step: step, taskPath: taskPath)
        writeMarkers()
    }
    
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
    
    /// The system clock time when the recorder was started.
    public private(set) var startUptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    
    /// The date timestamp for when the recorder was started.
    public private(set) var startDate: Date = Date()
    
    /// The identifier for tracking the current step.
    public private(set) var currentStepIdentifier: String = ""
    
    /// The current `stepPath` to record to log samples.
    public private(set) var currentStepPath: String = ""
    
    /// A conveniece method for calling the result handler on the main thread.
    private func callOnMainThread(_ result: RSDResult?, _ error: Error?, _ completion: RSDAsyncActionCompletionHandler?) {
        DispatchQueue.main.async {
            completion?(self, result, error)
        }
    }
    
    /// This method is called during startup after the logger is setup to start the recorder. The base class
    /// implementation will immediately call the completion handler. If an overriding class needs to do any
    /// initialization to start the recorder, then override this method. If the override calls the completion
    /// handler then **DO NOT** call super. This method is called from `start()` on the main thread queue.
    open func startRecorder(_ completion: RSDAsyncActionCompletionHandler?) {
        // In case the override doesn't move this back to the main thread, call completion on next run loop.
        callOnMainThread(self.result, nil, completion)
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
    open func stopRecorder(loggerError: Error?, _ completion: RSDAsyncActionCompletionHandler?) {
        // In case the override doesn't move this back to the main thread, call completion on next run loop.
        callOnMainThread(self.result, loggerError, completion)
    }
    
    /// This method can be called by either the logging file if there was a write error, or by the subclass
    /// if there was an error when attempting to record samples. The method will call the delegate method
    /// `asyncActionController(_, didFailWith:)` asynchronously on the main queue and will call `cancel()`
    /// synchronously on the current queue.
    open func didFail(with error: Error) {
        DispatchQueue.main.async {
            self.delegate?.asyncActionController(self, didFailWith: error)
        }
        cancel()
    }

    /// Append the `collectionResult` with the given result.
    /// - parameter result: The result to add to the collection.
    public func appendResults(_ result: RSDResult) {
        self.collectionResult.appendInputResults(with: result)
    }
    
    // MARK: Logger handling
    
    /// The serial queue used for writing samples to the log files. To ensure that write failures due to memory
    /// warnings do not get thrown by multiple threads, a single logging queue is used for writing to all the
    /// open log files.
    public let loggerQueue = DispatchQueue(label: "org.sagebase.ResearchSuite.Recorder.\(UUID())")
    
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
        return configuration.identifier
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
    
    /// Instatiate a marker for recording step transitions as well as start and stop points.
    /// The default implementation will instantiate a `RSDRecordMarker`.
    ///
    /// - parameters:
    ///     - uptime: The system clock time.
    ///     - date: The timestamp date.
    ///     - stepPath: The step path.
    ///     - loggerIdentifier: The identifier for the logger for which to create the marker.
    /// - returns: A sample to add to the log file that can be used as a step transition marker.
    open func instantiateMarker(uptime: TimeInterval, date: Date, stepPath: String, loggerIdentifier:String) -> RSDSampleRecord {
        return RSDRecordMarker(uptime: uptime, timestamp: uptime - self.startUptime, date: date, stepPath: stepPath)
    }
    
    /// Update the current step and step path.
    ///
    /// - parameters:
    ///     - step: The current step.
    ///     - taskPath: The current path.
    open func updateMarker(step: RSDStep?, taskPath: RSDTaskPath) {
        currentStepIdentifier = step?.identifier ?? ""
        let path = taskPath.fullPath
        currentStepPath = (path as NSString).appendingPathComponent(currentStepIdentifier)
    }
    
    /// Write a sample to the logger.
    /// - parameters:
    ///     - sample: sample: The sample to add to the logging file.
    ///     - loggerIdentifier: The identifier for the logger for which to create the marker. If nil, then the
    ///                         `defaultLoggerIdentifier` will be used.
    public final func writeSample(_ sample: RSDSampleRecord, loggerIdentifier:String? = nil) {
        self.loggerQueue.async {
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
    /// By default, the file will be created using the `RSDFileResultUtility.createFileURL()` utility method to create
    /// a URL in the `outputDirectory`. A `RSDRecordSampleLogger` is returned by default.
    ///
    /// - parameter identifier: The unique identifier for the logger.
    /// - returns: A new instance of a `RSDDataLogger`.
    /// - throws: An error if opening the log file failed.
    open func instantiateLogger(with identifier: String) throws -> RSDDataLogger? {
        let url = try RSDFileResultUtility.createFileURL(identifier: identifier, ext: "json", outputDirectory: outputDirectory)
        return try RSDRecordSampleLogger(identifier: identifier, url: url, usesRootDictionary: self.usesRootDictionary)
    }
    
    /// Write a marker to each logging file.
    private func writeMarkers() {
        let uptime = ProcessInfo.processInfo.systemUptime
        let date = Date()
        let stepPath = self.currentStepPath
        self.loggerQueue.async {
            do {
                for (identifier, dataLogger) in self.loggers {
                    guard let logger = dataLogger as? RSDRecordSampleLogger else { continue }
                    let marker = self.instantiateMarker(uptime: uptime, date: date, stepPath: stepPath, loggerIdentifier: identifier)
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
    private func _startLogger(at taskPath: RSDTaskPath) throws {
        updateMarker(step: taskPath.currentStep, taskPath: taskPath)
        for identifier in self.loggerIdentifiers {
            guard let dataLogger = try instantiateLogger(with: identifier) else {
                continue
            }
            loggers[identifier] = dataLogger
            if let logger = dataLogger as? RSDRecordSampleLogger {
                let marker = instantiateMarker(uptime: startUptime, date: startDate, stepPath: currentStepPath, loggerIdentifier: identifier)
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
                fileResult.startUptime = self.startUptime
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
    
    /// Default initializer. The initializer will automatically open the file and write the
    /// JSON root element and start the sample array.
    ///
    /// - parameters:
    ///     - identifier: A unique identifier for the logger.
    ///     - url: The url to the file.
    ///     - usesRootDictionary: Is the root element in the json file a dictionary?
    public init(identifier: String, url: URL, usesRootDictionary: Bool) throws {
        self.usesRootDictionary = usesRootDictionary
        
        let startText: String
        if usesRootDictionary {
            // If this json file uses a dictionary as its root, then add a start date timestamp
            // and a key for the items in the dictionary.
            startText =
            """
            {
            "startDate" : \(Date().jsonObject()),
            "items"     : [
            """
        } else {
            // Otherwise, just open the array
            startText = "[\n"
        }
        guard let data = startText.data(using: .utf8) else {
            throw RSDRecordSampleLoggerError.stringEncodingFailed(startText)
        }
        
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
        if sampleCount > 0 {
            // If this is not the first sample then write a period and line feed
            try write(",\n")
        }
        let jsonEncoder = RSDFactory.shared.createJSONEncoder()
        let wrapper = _EncodableSampleWrapper(record: sample)
        let data = try jsonEncoder.encode(wrapper)
        try write(data)
    }
    
    /// Close the file. This will write the end tag for the root element and then close the file handle.
    /// If there is an error thrown by writing the closing tag, then the file handle will be closed and
    /// the error will be rethrown.
    ///
    /// - throws: Error thrown when attempting to write the closing tag.
    public override func close() throws {
        // Write the json closure to the file
        let endText = usesRootDictionary ? "}]" : "\n]"
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

/// The wrapper is required b/c `JSONEncoder` does not implement the `Encoder` protocol.
/// Instead, it uses a private wrapper to box the encoded object.
fileprivate struct _EncodableSampleWrapper: Encodable {
    let record: RSDSampleRecord
    func encode(to encoder: Encoder) throws {
        try record.encode(to: encoder)
    }
}

extension RSDRecordMarker : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.uptime, .stepPath, .timestampDate, .timestamp]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .uptime:
                if idx != 0 { return false }
            case .stepPath:
                if idx != 1 { return false }
            case .timestampDate:
                if idx != 2 { return false }
            case .timestamp:
                if idx != 3 { return false }
            }
        }
        return keys.count == 4
    }
    
    static func examples() -> [Encodable] {
        let date = rsd_ISO8601TimestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!
        return [RSDRecordMarker(uptime: 12344.56, timestamp: 0, date: date, stepPath: "/Foo Task/sectionA/step1")]
    }
}

