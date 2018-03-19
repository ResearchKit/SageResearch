//
//  CRFHeartRateRecorder.swift
//  CardiorespiratoryFitness
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
import AVFoundation
import ResearchSuite

/// A hardcoded value used as the min confidence to include a recording.
public let CRFMinConfidence = 0.5

/// The minimum "red level" (number of pixels that are "red" dominant) to qualify as having the lens covered.
public let CRFMinRedLevel = 0.9

public protocol CRFHeartRateRecorderDelegate : RSDAsyncActionControllerDelegate {
    
    /// An optional view that can be used to show the user's finger while the lens is uncovered.
    var previewView: UIView! { get }
    
    /// Method call that the camera has finished loading.
    func didFinishStartingCamera()
}

public class CRFHeartRateRecorder : RSDSampleRecorder, CRFHeartRateVideoProcessorDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /// A delegate method for the view controller.
    public var crfDelegate: CRFHeartRateRecorderDelegate? {
        return self.delegate as? CRFHeartRateRecorderDelegate
    }
    
    public enum CRFHeartRateRecorderError : Error {
        case noBackCamera
    }
    
    /// Flag that indicates that the user's finger is recognized as covering the flash.
    @objc dynamic public private(set) var isCoveringLens: Bool = false

    /// Last calculated heartrate.
    @objc dynamic public private(set) var bpm: Int = 0
    
    /// Confidence for the last calculated heartrate.
    public private(set) var confidence: Double = 1
    
    public var heartRateConfiguration : CRFHeartRateStep? {
        return self.configuration as? CRFHeartRateStep
    }
    
    public override func requestPermissions(on viewController: UIViewController, _ completion: @escaping RSDAsyncActionCompletionHandler) {
        
        let status = RSDAudioVisualAuthorization.authorizationStatus(for: .camera)
        if status == .denied || status == .restricted {
            let error = RSDPermissionError.notAuthorized(.camera, status)
            self.updateStatus(to: .failed, error: error)
            completion(self, nil, error)
            return
        }
        
        guard status == .notDetermined else {
            self.updateStatus(to: .permissionGranted, error: nil)
            completion(self, nil, nil)
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                self.updateStatus(to: .permissionGranted, error: nil)
                completion(self, nil, nil)
            } else {
                let error = RSDPermissionError.notAuthorized(.camera, .denied)
                self.updateStatus(to: .failed, error: error)
                completion(self, nil, error)
            }
        }
    }
    
    public override func startRecorder(_ completion: @escaping ((RSDAsyncActionStatus, Error?) -> Void)) {
        do {
            try self._startSampling()
            completion(.running, nil)
        } catch let err {
            debugPrint("Failed to start camera: \(err)")
            completion(.failed, err)
        }
    }
    
    public override func stopRecorder(_ completion: @escaping ((RSDAsyncActionStatus) -> Void)) {
        
        updateStatus(to: .processingResults, error: nil)
        
        // Force turning off the flash
        if let captureDevice = _captureDevice {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.torchMode = .auto
                captureDevice.unlockForConfiguration()
            } catch {}
        }
        
        // Append the camera settings
        if let settings = self.heartRateConfiguration?.cameraSettings {
            self.appendResults(settings)
        }
        
        self._videoPreviewLayer?.removeFromSuperlayer()
        self._videoPreviewLayer = nil
        
        self._simulationTimer?.invalidate()
        self._simulationTimer = nil
        
        self._session?.stopRunning()
        self._session = nil

        if let url = self._videoProcessor?.videoURL {

            // Create and add the result
            var fileResult = RSDFileResultObject(identifier: self.videoIdentifier)
            fileResult.startDate = self.startDate
            fileResult.endDate = Date()
            fileResult.url = url
            fileResult.startUptime = self.startUptime
            fileResult.contentType = "video/mp4"
            self.appendResults(fileResult)

            // Close the video recorder
            updateStatus(to: .stopping, error: nil)
            self._videoProcessor.stopRecording() {
                completion(.finished)
            }
        } else {
            completion(.finished)
        }
    }
    
    private let processingQueue = DispatchQueue(label: "org.sagebase.ResearchSuite.heartrate.processing")

    private var _simulationTimer: Timer?
    private var _session: AVCaptureSession?
    private var _captureDevice: AVCaptureDevice?
    private var _videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var _loggingSamples: [CRFPixelSample] = []
    private var _previousSettings: CRFCameraSettings?
    
    private var _videoProcessor: CRFHeartRateVideoProcessor!
    
    deinit {
        _session?.stopRunning()
        _simulationTimer?.invalidate()
    }
    
    private func _getCaptureDevice() -> AVCaptureDevice? {
        // If this is an iPhone Plus then the lens that is closer to the flash is the telephoto lens
        let telephoto = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInTelephotoCamera, for: AVMediaType.video, position: .back)
        return telephoto ?? AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
    }
    
    private var videoIdentifier: String {
        return "\(self.configuration.identifier)_video"
    }
    
    private func _setupVideoRecorder(formatDescription: CMFormatDescription) {
        guard let saveVideo = self.heartRateConfiguration?.shouldSaveBuffer, saveVideo,
            let url = try? RSDFileResultUtility.createFileURL(identifier: videoIdentifier, ext: "mp4", outputDirectory: outputDirectory)
            else {
                return
        }
        let time = CMTime(seconds: self.startUptime, preferredTimescale: 1000000000)
        _videoProcessor.startRecording(to: url, startTime: time, formatDescription: formatDescription)
    }
    
    private func _startSampling() throws {
        guard !isSimulator else {
            _simulationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (_) in
                self?._fireSimulationTimer()
            })
            return
        }
        guard _session == nil else { return }
        
        // Create the session
        let session = AVCaptureSession()
        _session = session
        session.sessionPreset = AVCaptureSession.Preset.low
        
        // Retrieve the back camera and add as an input
        guard let captureDevice = _getCaptureDevice()
            else {
                throw CRFHeartRateRecorderError.noBackCamera
        }
        _captureDevice = captureDevice
        let input = try AVCaptureDeviceInput(device: captureDevice)
        session.addInput(input)
        
        let cameraSettings = self.heartRateConfiguration?.cameraSettings ?? CRFCameraSettings()
        
        // Find the max frame rate we can get from the given device
        var currentFormat: AVCaptureDevice.Format!
        for format in captureDevice.formats {
            guard let frameRates = format.videoSupportedFrameRateRanges.first,
                frameRates.maxFrameRate == Double(cameraSettings.frameRate)
                else {
                    continue
            }
            
            // If this is the first valid format found then set it and continue
            if (currentFormat == nil) {
                currentFormat = format
                continue
            }
            
            // Find the lowest resolution format at the frame rate we want.
            let currentSize = CMVideoFormatDescriptionGetDimensions(currentFormat.formatDescription)
            let formatSize = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            if formatSize.width < currentSize.width && formatSize.height < currentSize.height {
                currentFormat = format
            }
        }
        
        // Initialize the processor
        let frameRate = cameraSettings.frameRate
        if !CRFSupportedFrameRates.contains(frameRate) {
            // Allow the camera settings to set the framerate to a value that is not supported to allow for
            // customization of the camera settings.
            debugPrint("WARNING!! \(frameRate) is NOT a supported framerate for calculating BPM.")
        }
        _videoProcessor = CRFHeartRateVideoProcessor(delegate: self, frameRate: Int32(frameRate), callbackQueue: processingQueue)

        // Tell the device to use the max frame rate.
        try captureDevice.lockForConfiguration()
        
        // Turn on the flash
        captureDevice.torchMode = .on
        
        // Set the format
        captureDevice.activeFormat = currentFormat
        
        // Set the frame rate
        captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, _videoProcessor.frameRate)
        captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, _videoProcessor.frameRate)
        
        // Belt & suspenders. For currently supported devices, HDR is not supported for the lowest
        // resolution format (which is what this recorder uses), but in case a device comes out that
        // does support HDR, then be sure to turn it off.
        if currentFormat.isVideoHDRSupported {
            captureDevice.isVideoHDREnabled = false
            captureDevice.automaticallyAdjustsVideoHDREnabled = false
        }

        // Lock the camera focus (if available) otherwise restrict the range.
        if captureDevice.isLockingFocusWithCustomLensPositionSupported {
            captureDevice.setFocusModeLocked(lensPosition: cameraSettings.focusLensPosition, completionHandler: nil)
        } else if captureDevice.isAutoFocusRangeRestrictionSupported {
            captureDevice.autoFocusRangeRestriction = (cameraSettings.focusLensPosition >= 0.5) ? .far : .near
            if captureDevice.isFocusPointOfInterestSupported {
                captureDevice.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
        }
        
        // Set the exposure time (shutter speed) and ISO
        if captureDevice.isExposureModeSupported(.custom) {
            let duration = CMTime(seconds: cameraSettings.exposureDuration, preferredTimescale: 1000)
            let iso = min(max(cameraSettings.iso, currentFormat.minISO), currentFormat.maxISO)
            captureDevice.setExposureModeCustom(duration: duration, iso: iso, completionHandler: nil)
        }
        
        // Set the white balance
        if captureDevice.isWhiteBalanceModeSupported(.locked) {
            let wb = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: cameraSettings.whiteBalance.temperature,
                                                                          tint: cameraSettings.whiteBalance.tint)
            let gains = captureDevice.deviceWhiteBalanceGains(for: wb)
            captureDevice.setWhiteBalanceModeLocked(with: gains, completionHandler: nil)
        }

        captureDevice.unlockForConfiguration()
        
        // Set the output
        let videoOutput = AVCaptureVideoDataOutput()
        
        // create a queue to run the capture on
        let captureQueue = DispatchQueue(label: "org.sagebase.ResearchSuite.heartrate.capture.\(configuration.identifier)")
        videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
        
        // set up the video output
        videoOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = false
        
        // start the video recorder (if there is one)
        _setupVideoRecorder(formatDescription: currentFormat.formatDescription)
        
        // Check to see if there is a preview window
        if let view = self.crfDelegate?.previewView {
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            _videoPreviewLayer = videoPreviewLayer
            view.layer.addSublayer(videoPreviewLayer)
        }

        // Add the output and start running
        session.addOutput(videoOutput)
        session.startRunning()
    }
    
    private func _fireSimulationTimer() {
        let uptime = ProcessInfo.processInfo.systemUptime
        guard uptime - startUptime > 2 else { return }
        guard uptime - startUptime > Double(CRFHeartRateSettleSeconds + CRFHeartRateWindowSeconds) else {
            if !isCoveringLens {
                isCoveringLens = true
            }
            return
        }
        if Int(uptime - self.startUptime) % 5 == 0 {
            self.sampleProcessingQueue.async {
                let heartRate = 65
                let confidence = 0.75
                
                let bpmSample = CRFHeartRateBPMSample(uptime: uptime, bpm: heartRate, confidence: confidence)
                self.bpmSamples.append(bpmSample)
                
                if confidence > CRFMinConfidence {
                    DispatchQueue.main.async {
                        self.confidence = confidence
                        self.bpm = heartRate
                    }
                }
            }
        }
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.crfDelegate?.didFinishStartingCamera()
        _videoProcessor.appendVideoSampleBuffer(sampleBuffer)
    }

    // MARK: CRFHeartRateVideoProcessorDelegate
    
    public func processor(_ processor: CRFHeartRateVideoProcessor, didCapture sample: CRFPixelSample) {
        _recordColor(sample)
    }
    
    private func _recordColor(_ sample: CRFPixelSample) {
        
        // mark a change in whether or not the lens is covered
        let coveringLens = sample.isCoveringLens()
        if coveringLens != self.isCoveringLens {
            DispatchQueue.main.async {
                self.isCoveringLens = coveringLens
                if let previewLayer = self._videoPreviewLayer {
                    if coveringLens {
                        previewLayer.removeFromSuperlayer()
                    } else {
                        self.crfDelegate?.previewView?.layer.addSublayer(previewLayer)
                    }
                }
            }
        }
        
        // If not covering the lens then check that everything is still on
        if !coveringLens, let device = _captureDevice, device.torchMode != .on {
            do {
                try device.lockForConfiguration()
                device.torchMode = .on
                device.unlockForConfiguration()
            } catch let err {
                self.didFail(with: err)
            }
        }
        
        // Process the pixel sample.
        _processSample(sample)
        
        // Add the sample to the logging queue and write in 1 second batches.
        _loggingSamples.append(sample)
        if _loggingSamples.count >= _videoProcessor.frameRate {
            let samples = _loggingSamples.sorted(by: { $0.uptime < $1.uptime })
            _loggingSamples.removeAll()
            self.writeSamples(samples)
        }
    }
    
    // Heart rate processing
    
    /// The processed samples.
    public private(set) var bpmSamples : [CRFHeartRateBPMSample] = []
    
    /// Is the heart rate currently being calculated?
    internal var isProcessing: Bool = false
    
    private let arrayMutatingQueue = DispatchQueue(label: "org.sagebase.CRF.sample.mutating")
    private let sampleProcessingQueue = DispatchQueue(label: "org.sagebase.CRF.sample.processing")
    
    /// Samples collector used to store the samples in memory for each half-window.
    private var pixelSamples : [CRFPixelSample] = []
    
    /// Add the sample.
    func _processSample(_ sample: CRFPixelSample) {
        guard sample.isCoveringLens() else { return }
        arrayMutatingQueue.async {
            
            // append the samples
            self.pixelSamples.append(sample)
            
            // look to see if we have enough to process a bpm
            let windowLength = Int(CRFHeartRateWindowSeconds) * Int(self._videoProcessor.frameRate)
            if self.pixelSamples.count >= windowLength {
                
                // Set flag that the samples are being processed
                self.isProcessing = true
                
                // get the red channel and the uptime then remove the first half the samples
                let halfLength = windowLength / 2
                let uptime = self.pixelSamples[Int(halfLength)].uptime
                let channel = self.pixelSamples[..<windowLength].map { $0.green }
                self.pixelSamples.removeSubrange(..<halfLength)
                
                self.sampleProcessingQueue.async {
                    
                    let (heartRate, confidence) = calculateHeartRate(channel)
                    let bpmSample = CRFHeartRateBPMSample(uptime: uptime, bpm: heartRate, confidence: confidence)
                    self.bpmSamples.append(bpmSample)
                    self.isProcessing = false
                    
                    if confidence > CRFMinConfidence {
                        DispatchQueue.main.async {
                            self.confidence = confidence
                            self.bpm = heartRate
                        }
                    }
                }
            }
        }
    }
}

public struct CRFHeartRateSamplesResult : RSDResult, RSDArchivable {
    
    /// The identifier for this result.
    public let identifier: String
    
    /// The result type.
    public var type: RSDResultType = "heartRateSamples"
    
    /// Start date.
    public var startDate: Date = Date()
    
    /// End date.
    public var endDate: Date = Date()
    
    /// The samples for this result.
    public let samples: [CRFHeartRateBPMSample]
    
    public init(identifier: String, samples: [CRFHeartRateBPMSample]) {
        self.identifier = identifier
        self.samples = samples
    }
    
    public func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)? {
        let data = try self.jsonEncodedData()
        let filename = RSDFileResultUtility.filename(for: identifier)
        let manifest = RSDFileManifest(filename: filename, timestamp: self.endDate, contentType: "application/json", identifier: identifier, stepPath: stepPath)
        return (manifest, data)
    }
}

public struct CRFHeartRateBPMSample : RSDSampleRecord, RSDDelimiterSeparatedEncodable {
    
    private enum CodingKeys : String, CodingKey {
        case uptime, bpm, confidence
    }
    
    /// The uptime marker for the bpm sample.
    public let uptime: TimeInterval
    
    /// The calculated BPM for this sample.
    public let bpm: Int?
    
    /// The confidence in the calculated BPM for this sample.
    public let confidence: Double?
    
    init(uptime: TimeInterval, bpm: Int, confidence: Double) {
        self.uptime = uptime
        self.bpm = bpm
        self.confidence = confidence
    }
    
    public static func codingKeys() -> [CodingKey] {
        return _codingKeys()
    }
    
    private static func _codingKeys() -> [CodingKeys] {
        return [.uptime, .bpm, .confidence]
    }
    
    // Ignored
    
    public var timestamp: TimeInterval? { return nil }
    public var timestampDate: Date? { return nil }
    public var stepPath: String { return "" }
}

extension CRFPixelSample : RSDSampleRecord, RSDDelimiterSeparatedEncodable {
    
    private enum CodingKeys : String, CodingKey {
        case uptime, red, green, blue, redLevel
    }
    
    /// Is the user's finger covering the lens?
    public func isCoveringLens() -> Bool {
        // If the red level isn't high enough then exit with false.
        guard (redLevel >= CRFMinRedLevel) && (red > green) && (red > blue)
            else {
                return false
        }
        
        // Calculate hue and saturation.
        let minValue = min(green, blue)
        let maxValue = red
        let delta = maxValue - minValue
        var hue = 60 * ((green - blue) / delta)
        if (hue < 0) {
            hue += 360
        }
        let saturation = delta / maxValue
        
        // Look for the hue to be in the red zone and the saturation to be fairly high.
        return (hue <= 30 || hue >= 350) && (saturation >= 0.7)
    }
    
    // MARK: Encoding and Decoding
    
    public static func codingKeys() -> [CodingKey] {
        return _codingKeys()
    }
    
    private static func _codingKeys() -> [CodingKeys] {
        return [.uptime, .red, .blue, .green, .redLevel]
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uptime = try container.decode(Double.self, forKey: .uptime)
        self.red = try container.decode(Double.self, forKey: .red)
        self.green = try container.decode(Double.self, forKey: .green)
        self.blue = try container.decode(Double.self, forKey: .blue)
        self.redLevel = try container.decode(Double.self, forKey: .redLevel)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.uptime, forKey: .uptime)
        try container.encode(self.red, forKey: .red)
        try container.encode(self.green, forKey: .green)
        try container.encode(self.blue, forKey: .blue)
        try container.encode(self.redLevel, forKey: .redLevel)
    }
    
    // Ignored
    
    public var timestamp: TimeInterval? { return nil }
    public var timestampDate: Date? { return nil }
    public var stepPath: String { return "" }
}
