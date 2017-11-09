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

public protocol RSDSampleRecord : Codable {
    
    /**
     The clock uptime. See `ProcessInfo.processInfo.systemUptime`.
     */
    var uptime: TimeInterval { get }
    
    /**
     An identifier marking the current step.
     */
    var stepPath: String { get }
    
    /**
     The date timestamp when the measurement was taken (if available).
     */
    var date: Date? { get }
    
    /**
     Relative time to when the recorder was started.
     */
    var timestamp: TimeInterval { get }
}

public protocol RSDSampleRecordType {
    associatedtype SampleType : RSDSampleRecord
}

public struct RSDRecordMarker : RSDSampleRecord {
    public let uptime: TimeInterval
    public let stepPath: String
    public let date: Date?
    public let timestamp: TimeInterval
    
    public init(uptime: TimeInterval, timestamp: TimeInterval, date: Date, stepPath: String) {
        self.uptime = uptime
        self.timestamp = timestamp
        self.stepPath = stepPath
        self.date = date
    }
}

/**
 A base-class implementation of a controller that is used to record samples.
 */
open class RSDSampleRecorder : NSObject, RSDAsyncActionController {

    public enum RSDRecorderError : Error {
        case alreadyRunning
        case cancelled
    }
    
    open weak var delegate: RSDAsyncActionControllerDelegate?
    public let configuration: RSDAsyncActionConfiguration
    
    public var result: RSDResult? {
        guard collectionResult.inputResults.count > 0 else { return nil }
        if collectionResult.inputResults.count == 1 {
            return collectionResult.inputResults.first
        } else {
            return collectionResult
        }
    }
    
    // MARK: State management
    
    public let isSimulator: Bool = {
        #if (arch(i386) || arch(x86_64)) && !os(OSX)
            return true
        #else
            return false
        #endif
    }()
    
    @objc dynamic open var isRunning: Bool {
        return logger != nil
    }
    
    @objc dynamic open private(set) var isPaused: Bool = false
    @objc dynamic open private(set) var isCancelled: Bool = false
    
    public private(set) var collectionResult: RSDCollectionResultObject
    public private(set) var startUptime: TimeInterval = ProcessInfo.processInfo.systemUptime
    public private(set) var startDate: Date = Date()
    public private(set) var currentStepIdentifier: String = ""
    public private(set) var currentStepPath: String = ""
    
    public init(configuration: RSDAsyncActionConfiguration, outputDirectory: URL) {
        self.configuration = configuration
        self.outputDirectory = outputDirectory
        self.collectionResult = RSDCollectionResultObject(identifier: configuration.identifier)
    }
    
    public final func start(at taskPath: RSDTaskPath?, completion: RSDAsyncActionCompletionHandler?) {
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
    
    public func callOnMainThread(_ result: RSDResult?, _ error: Error?, _ completion: RSDAsyncActionCompletionHandler?) {
        DispatchQueue.main.async {
            completion?(self, result, error)
        }
    }
    
    /**
     This method is called during startup after the logger is setup to start the recorder. The base class implementation will immediately call the completion handler. If an overriding class needs to do any initialization to start the recorder, then override this method. If the override calls the completion handler then DO NOT call super. This method is called on the main thread queue.
     */
    open func startRecorder(_ completion: RSDAsyncActionCompletionHandler?) {
        // In case the override doesn't move this back to the main thread, call completion on next run loop.
        callOnMainThread(self.result, nil, completion)
    }
    
    open func pause() {
        isPaused = true
    }
    
    open func resume() {
        isPaused = false
    }
    
    public final func stop() {
        stop(nil)
    }
    
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
    
    /**
     This method is called during finish after the logger is closed. The base class implementation will immediately call the completion handler. If an overriding class needs to do any actions to stop the recorder, then override this method. If the override calls the completion handler then DO NOT call super. Otherwise, super will call the completion with the logger error as the input to the completion handler. This method is called on the main thread queue.
     */
    open func stopRecorder(loggerError: Error?, _ completion: RSDAsyncActionCompletionHandler?) {
        // In case the override doesn't move this back to the main thread, call completion on next run loop.
        callOnMainThread(self.result, loggerError, completion)
    }
    
    open func didFail(with error: Error) {
        DispatchQueue.main.async {
            self.delegate?.asyncActionController(self, didFailWith: error)
        }
        cancel()
    }
    
    open func cancel() {
        isCancelled = true
        stop()
    }
    
    open func moveTo(step: RSDStep, taskPath: RSDTaskPath) {
        updateMarker(step: step, taskPath: taskPath)
        let marker = instantiateMarker(uptime: ProcessInfo.processInfo.systemUptime, date: Date(), stepPath: currentStepPath)
        writeSample(marker)
    }
    
    public func appendResults(_ result: RSDResult) {
        self.collectionResult.appendInputResults(with: result)
    }
    
    // MARK: Logger
    
    public private(set) var logger: RSDRecordSampleLogger?
    public let outputDirectory: URL
    public let loggerQueue = DispatchQueue(label: "org.sagebase.ResearchSuite.Recorder.\(UUID())")
    
    open func instantiateMarker(uptime: TimeInterval, date: Date, stepPath: String) -> RSDSampleRecord {
        return RSDRecordMarker(uptime: uptime, timestamp: uptime - self.startUptime, date: date, stepPath: stepPath)
    }
    
    open func updateMarker(step: RSDStep?, taskPath: RSDTaskPath?) {
        currentStepIdentifier = step?.identifier ?? ""
        let path = taskPath?.fullPath ?? ""
        currentStepPath = path + "\\" + currentStepIdentifier
    }
    
    public final func writeSample(_ sample: RSDSampleRecord) {
        self.loggerQueue.async {
            guard let logger = self.logger else { return }
            do {
                try logger.writeSample(sample)
            } catch let err {
                DispatchQueue.global().async {
                    self.didFail(with: err)
                }
            }
        }
    }
    
    public final func writeSamples(_ samples: [RSDSampleRecord]) {
        self.loggerQueue.async {
            // Check that the logger hasn't been closed and nil'd
            guard let logger = self.logger else { return }
            do {
                try logger.writeSamples(samples)
            } catch let err {
                DispatchQueue.global().async {
                    self.didFail(with: err)
                }
            }
        }
    }
    
    private func _startLogger(at taskPath: RSDTaskPath?) throws {
        logger = try RSDRecordSampleLogger(identifier: self.configuration.identifier, outputDirectory: outputDirectory)
        updateMarker(step: taskPath?.currentStep, taskPath: taskPath)
        let marker = instantiateMarker(uptime: startUptime, date: startDate, stepPath: currentStepPath)
        try logger!.writeSample(marker)
    }
    
    private func _stopLogger() throws {
        guard let aLogger = logger else {
            return
        }
        // Nil out the logger before closing in case closing throws an error
        logger = nil
        try aLogger.close()
        
        // Create and add the result
        var fileResult = RSDFileResultObject(identifier: self.configuration.identifier)
        fileResult.startDate = self.startDate
        fileResult.endDate = Date()
        fileResult.url = aLogger.url
        fileResult.startUptime = self.startUptime
        self.appendResults(fileResult)
    }
}

/**
 `RSDRecordSampleLogger` is used to write samples encoded as json dictionary objects to a logging file.
 */
public class RSDRecordSampleLogger {
    
    public enum RSDRecordSampleLoggerError : Error {
        case stringEncodingFailed(String)
    }
    
    /**
     Is the root element in the json file a dictionary?
     */
    public let isRootDictionary: Bool
    
    /**
     The url to the file.
     */
    public let url: URL
    
    /**
     Open file handle for writing to the logger
     */
    private let fileHandle: FileHandle
    
    /**
     Number of samples written to the file.
     */
    public private(set) var sampleCount: Int = 0
    
    public convenience init(identifier: String, outputDirectory: URL, isRootDictionary: Bool = false) throws {
        
        // Scrub non-alphanumeric characters from the identifer
        var characterSet = CharacterSet.alphanumerics
        characterSet.invert()
        var scrubbedIdentifier = identifier
        while let range = scrubbedIdentifier.rangeOfCharacter(from: characterSet) {
            scrubbedIdentifier.removeSubrange(range)
        }
        scrubbedIdentifier = String(scrubbedIdentifier.prefix(12))
        let directory = scrubbedIdentifier.count > 0 ? scrubbedIdentifier : "temp"
        
        // create the directory if needed
        let dirURL = outputDirectory.appendingPathComponent(directory, isDirectory: true)
        try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)

        // Use the first 8 characters of a UUID string for the filename
        let uuid = UUID().uuidString
        let filename = String(uuid.prefix(8))
        let url = dirURL.appendingPathComponent(filename, isDirectory: false).appendingPathExtension("json")
        
        try self.init(url: url, isRootDictionary: isRootDictionary)
    }
    
    public init(url: URL, isRootDictionary: Bool) throws {
        self.url = url
        self.isRootDictionary = isRootDictionary
        
        let startText: String
        if isRootDictionary {
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
        try startText.write(to: url, atomically: false, encoding: .utf8)
        
        self.fileHandle = try FileHandle(forWritingTo: url)
    }
    
    public func writeSamples(_ samples: [RSDSampleRecord]) throws {
        for sample in samples {
            try writeSample(sample)
        }
    }
    
    public func writeSample(_ sample: RSDSampleRecord) throws {
        if sampleCount > 0 {
            // If this is not the first sample then write a period and line feed
            try write(",\n")
        }
        let jsonEncoder = RSDFactory.shared.createJSONEncoder()
        let wrapper = _EncodableSampleWrapper(record: sample)
        let data = try jsonEncoder.encode(wrapper)
        try write(data)
        sampleCount += 1
    }
    
    private func write(_ string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw RSDRecordSampleLoggerError.stringEncodingFailed(string)
        }
        try write(data)
    }
    
    private func write(_ data: Data) throws {
        // Write the opening
        try RSDExceptionHandler.try {
            self.fileHandle.seekToEndOfFile()
            self.fileHandle.write(data)
        }
    }
    
    public func close() throws {
        // Write the json closure to the file
        let endText = isRootDictionary ? "}]" : "\n]"
        try write(endText)
        self.fileHandle.closeFile()
    }
}

fileprivate struct _EncodableSampleWrapper: Encodable {
    let record: RSDSampleRecord
    func encode(to encoder: Encoder) throws {
        try record.encode(to: encoder)
    }
}

