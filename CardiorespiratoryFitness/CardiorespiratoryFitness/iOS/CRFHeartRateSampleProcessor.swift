//
//  CRFHeartRateSampleProcessor.swift
//  CardiorespiratoryFitness
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

import Foundation

import UIKit

/// Frame rates supported by this processor, with the preferred framerate listed first.
public let CRFSupportedFrameRates = [Int(fs)]

/// The number of seconds for the window used to calculate the heart rate.
public let CRFHeartRateWindowSeconds = TimeInterval(window)

/// The number of seconds for the window used to calculate the heart rate.
public let CRFHeartRateWindowOverlapSeconds = TimeInterval(1)

/// The number of seconds to let the sampler settle before looking at the heart rate.
public let CRFHeartRateSettleSeconds = TimeInterval(3)

/// The minimum heart rate calculated with this app.
public let CRFMinHeartRate = Double(45)

/// The maximum heart rate calculated with this app.
public let CRFMaxHeartRate = Double(210)

/// Minimum frame rate supported by this processor.
public let CRFMinFrameRate = Double(12)

fileprivate let fs: Double = 60                                 // frames / second
fileprivate let window: Double = 10                             // seconds
fileprivate let window_len: Int = Int(round(fs * window))       // number of frames in the window

protocol PixelSample {
    var presentationTimestamp: Double { get }
    var red: Double { get }
    var green: Double { get }
    var blue: Double { get }
    var isCoveringLens: Bool { get }
}

internal class CRFHeartRateSampleProcessor {
    
    /// The processed samples.
    internal private(set) var bpmSamples : [CRFHeartRateBPMSample] = []
    
    /// Is the heart rate currently being calculated?
    var isProcessing: Bool = false
    
    /// The callback for returning processed bpm and confidence from runnning sample processing.
    var callback: ((_ bpm: Double, _ confidence: Double) -> Void)?
    
    private let arrayMutatingQueue = DispatchQueue(label: "org.sagebase.CRF.sample.mutating")
    private let sampleProcessingQueue = DispatchQueue(label: "org.sagebase.CRF.sample.processing")
    
    /// Samples collector used to store the samples in memory for each half-window.
    private var pixelSamples : [PixelSample] = []
    
    func reset() {
        self.arrayMutatingQueue.async {
            self.pixelSamples.removeAll()
            self.sampleProcessingQueue.async {
                self.bpmSamples.removeAll()
                DispatchQueue.main.async {
                    self.callback?(0, 0)
                }
            }
        }
    }
    
    func restingHeartRate() -> CRFHeartRateBPMSample? {
        guard self.bpmSamples.count > 0,
            let sample = self.bpmSamples.sorted(by: { $0.confidence > $1.confidence }).first,
            sample.confidence >= CRFMinConfidence
            else {
                return nil
        }
        return sample
    }
    
    func peakHeartRate() -> CRFHeartRateBPMSample? {
        guard self.bpmSamples.count > 0 else { return nil }
        let highConfidenceSamples = self.bpmSamples.filter { $0.confidence >= CRFMinConfidence }
        return highConfidenceSamples.first
    }
    
    func endHeartRate() -> CRFHeartRateBPMSample? {
        guard self.bpmSamples.count > 0 else { return nil }
        let highConfidenceSamples = self.bpmSamples.filter { $0.confidence >= CRFMinConfidence }
        return highConfidenceSamples.last
    }
    
    func vo2Max(sex: CRFSex, age: Double, startTime: TimeInterval) -> (Double, Double)? {
        let highConfidenceSamples = self.bpmSamples.filter {
            $0.confidence >= CRFMinConfidence &&
                ($0.timestamp ?? 0) >= startTime
        }
        guard highConfidenceSamples.count > 1 else { return nil }
        
        let meanHR = highConfidenceSamples.map({ $0.bpm }).mean()
        let beats30to60 = meanHR / 2
        let vo2Center: Double = {
            switch sex {
            case .female:
                return 83.477 - (0.586 * beats30to60) - (0.404 * age) - 7.030
            case .male:
                return 83.477 - (0.586 * beats30to60) - (0.404 * age)
            default:
                return 84.687 - (0.722 * beats30to60) - (0.383 * age)
            }
        }()
        return (vo2Center, vo2Center)
    }
    
    func simulatorProcessSample(timestamp: TimeInterval) {
        self.sampleProcessingQueue.async {
            let bpm: Double = 65
            let confidence = 0.75
            let bpmSample = CRFHeartRateBPMSample(timestamp: timestamp, bpm: bpm, confidence: confidence)
            self.bpmSamples.append(bpmSample)
            DispatchQueue.main.async {
                self.callback?(bpm, confidence)
            }
        }
    }
    
    /// Add the sample.
    func processSample(_ sample: PixelSample) {
        
        arrayMutatingQueue.async {
            
            // Do not start savinng samples if the lens has not yet been covered
            guard self.pixelSamples.count > 0 || sample.isCoveringLens else { return }
            
            // append the samples
            self.pixelSamples.append(sample)
            
            // look to see if we have enough to process a bpm
            guard let frameRate = self.estimatedSamplingRate(from: self.pixelSamples) else { return }
            let roundedRate = Int(round(frameRate))
            
            // Need to keep 2 extra seconds due to filtering lopping off the first 2 seconds of data.
            let meanOrder = self.meanFilterOrder(for: roundedRate)
            let windowLength = Int(CRFHeartRateWindowSeconds + 2) * roundedRate + meanOrder
            if self.pixelSamples.count >= windowLength {
                
                // set flag that the samples are being processed
                self.isProcessing = true
                
                // get the red and green channels and the uptime
                let samples = self.pixelSamples//.suffix(windowLength)
                let timestamp = samples.last!.presentationTimestamp
                // TODO: syoung 04/10/2019 Figure out why this was here, looking at previous confidence window
                // and removing 5 seconds worth of samples if the confidence is good. My guess is that it is
                // to reduce fluctuation in the UI between --- and a valid heart rate. (ie. Don't show the
                // "bad" heart rate values unless they are really bad) But could probably improve smoothing
                // this out, especially for the case where the heart rate is for recovery and should be going
                // down.
                let removeLength = //(self.confidence >= CRFMinConfidence) ? halfLength :
                    roundedRate
                self.pixelSamples.removeSubrange(..<removeLength)
                
                self.sampleProcessingQueue.async {
                    
                    let redChannel = samples.map { $0.red }
                    let greenChannel = samples.map { $0.green }
                    let red = self.calculateHeartRate(redChannel, samplingRate: frameRate)
                    let green = self.calculateHeartRate(greenChannel, samplingRate: frameRate)
                    let pixelChannel: CRFPixelChannel = (red.confidence > green.confidence) ? .red : .green
                    let (bpm, confidence) = (red.confidence > green.confidence) ? red : green
                    
                    let bpmSample = CRFHeartRateBPMSample(timestamp: timestamp, bpm: bpm, confidence: confidence, channel: pixelChannel)
                    self.bpmSamples.append(bpmSample)
                    self.isProcessing = false
                    print("\(pixelChannel) bpm=\(bpm), confidence=\(confidence)")
                    
                    DispatchQueue.main.async {
                        self.callback?(bpm, confidence)
                    }
                }
            }
        }
    }
    
    /// Estimated sampling rate will return nil if there are not enough samples to return a rate.
    func estimatedSamplingRate(from samples:[PixelSample]) -> Double? {
        // Look to see if the sampling rate can be estimated.
        guard Double(samples.count) >= CRFHeartRateWindowSeconds * CRFMinFrameRate else { return nil }
        return calculateSamplingRate(from: samples)
    }
    
    /// Calculate the sampling rate.
    func calculateSamplingRate(from samples:[PixelSample]) -> Double {
        guard let start: (Int, PixelSample) = samples.enumerated().first(where: { $1.isCoveringLens }),
            let endTime = samples.last?.presentationTimestamp
            else {
                return 0
        }
        
        let startTime = start.1.presentationTimestamp
        let diff = endTime - startTime
        guard diff > 0
            else {
                return 0
        }
        let count = Double(samples.count - start.0)
        return count / diff
    }

    /// A valid sampling rate has filter coefficients defined for high and low pass.
    func isValidSamplingRate(_ samplingRate: Int) -> Bool {
        guard let _ = lowPassParameters.filterParams(for: samplingRate),
            let _ = highPassParameters.filterParams(for: samplingRate)
            else {
                return false
        }
        return true
    }

    // MARK: Code ported from R
    // - note: R is indexed from 1 so to simplify porting the code, everything is offset by one
    // in the filters before calculating.
    
    func calculateHeartRate(_ input: [Double], samplingRate: Double) -> (heartRate: Double, confidence: Double) {
        let window = Int(ceil(CRFHeartRateWindowSeconds * samplingRate))
        guard let filtered = getFilteredSignal(input, samplingRate: Int(round(samplingRate))),
            filtered.count >= window
            else {
                return (0, 0)
        }
        let chunked = Array(filtered[(filtered.count-window)...])
        return getHR(from: chunked, samplingRate: samplingRate)
    }
    
    //    #' Given a processed time series find its period using autocorrelation
    //    #' and then convert it to heart rate (bpm)
    //    #'
    //    #' @param x A time series numeric data
    //    #' @param sampling_rate The sampling rate (fs) of the time series data
    //    #' @param method The algorithm used to estimate the heartrate, because the
    //    #' preprocessing steps are different for each. method can be any of
    //    #' 'acf','psd' or 'peak' for algorithms based on autocorrelation,
    //    #' power spectral density and peak picking respectively
    //    #' @param min_hr Minimum expected heart rate
    //    #' @param max_hr Maximum expected heart rate
    //    #' @return A named vector containing heart rate and the confidence of the result
    //    get_hr_from_time_series <- function(x, sampling_rate, method = 'acf', min_hr = 45, max_hr=210) {
    func getHR(from filteredInput: [Double], samplingRate: Double) -> (heartRate: Double, confidence: Double) {

        guard let (x, y, minLag, maxLag) = preprocessSamples(filteredInput, samplingRate: samplingRate)
            else {
                return (0,0)
        }
        
        let (y_max, y_max_pos, y_min, hr_initial_guess) = getBounds(y: y, samplingRate: samplingRate)
        guard let aliasedPeak = getAliasingPeakLocation(hr: hr_initial_guess,
                                                        actualLag: y_max_pos,
                                                        samplingRate: samplingRate,
                                                        minLag: minLag,
                                                        maxLag: maxLag)
            else {
                return (0,0)
        }
        
        let hr: Double
        let confidence: Double

        if aliasedPeak.earlier.count > 0 {
            // peak_pos_thresholding_result <- (y[aliasedPeak$earlier_peak]-y_min) > 0.7*(y_max-y_min)
            // # Check which of the earlier peak(s) satisfy the threshold
            let peak_pos = aliasedPeak.earlier.filter {
                (y[$0] - y_min) > 0.7 * (y_max - y_min)
            }
            
            // # Subset to those earlier peak(s) that satisfy the thresholding criterion above
            if peak_pos.count > 0 {

                // # Estimate heartrates for each of the peaks that satisfy the thresholding criterion
                let hr_vec = peak_pos.map { (60 * samplingRate) / Double($0 - 1) }
                hr = hr_vec.mean()

                // confidence <- mean(y[peak_pos]-y_min)/(max(x)-min(x))
                // # Estimate the confidence based on the peaks that satisfy the threshold
                confidence = peak_pos.map({ y[$0] - y_min }).mean() / (x.max()! - x.min()!)
            }
            else {
                hr = hr_initial_guess
                confidence = y_max / x.max()!
            }
        }
        // # Get into this loop if no earlier peak was picked up during getAliasingPeakLocation
        else if aliasedPeak.later.count > 0, aliasedPeak.later.reduce(true, { $0 && (y[$1] > 0.7 * y_max) }) {
            hr = hr_initial_guess
            confidence = y_max / x.max()!
        }
        else {
            return (0, 0)
        }
        
        return (hr, confidence)
    }
    
    func calculateMinLag(samplingRate: Double) -> Int {
        return Int(round(60 * samplingRate / CRFMaxHeartRate))
    }
    
    func calculateMaxLag(samplingRate: Double) -> Int {
        return Int(round(60 * samplingRate / CRFMinHeartRate))
    }
    
    func preprocessSamples(_ input: [Double], samplingRate: Double) -> (x: [Double], y: [Double], minLag: Int, maxLag: Int)? {
        //    max_lag = round(60 * sampling_rate / min_hr) # 4/3 fs is 45BPM
        let maxLag = calculateMaxLag(samplingRate: samplingRate)
        //    min_lag = round(60 * sampling_rate / max_hr) # 1/3.5 fs is 210BPM
        let minLag = calculateMinLag(samplingRate: samplingRate)
        //    x <- stats::acf(x, lag.max = max_lag, plot = F)$acf
        let x = autocorrelation(input, lagMax: maxLag).offsetR()
        
        // Check that the sampling rate is valid and the max/min are within range.
        let roundedSamplingRate = Int(round(samplingRate))
        guard isValidSamplingRate(roundedSamplingRate),
            maxLag < x.count, minLag < maxLag, minLag > 0
            else {
                return nil
        }
        
        //    y <- 0 * x
        //    y[seq(min_lag, max_lag)] <- x[seq(min_lag, max_lag)]
        var y = Array(repeating: Double(0), count: x.count)
        for ii in minLag...maxLag {
            y[ii] = x[ii]
        }
        
        return (x, y, minLag, maxLag)
    }
    
    func getBounds(y: [Double], samplingRate: Double) -> (y_max: Double, y_max_pos: Int, y_min: Double, hr_initial_guess: Double) {
        //    y_max_pos <- which.max(y)
        //    y_max <- max(y)
        //    y_min <- min(y)
        let (y_max, y_max_pos) = y.seekMax()
        let y_min = y.min()!
        
        //    hr_initial_guess <- 60 * sampling_rate / (y_max_pos - 1)
        let hr_initial_guess = (60.0 * samplingRate) / Double(y_max_pos - 1)
        
        return (y_max, y_max_pos, y_min, hr_initial_guess)
    }
    
    
    func getAliasingPeakLocation(hr: Double, actualLag: Int, samplingRate: Double, minLag: Int, maxLag: Int) -> (nPeaks: Int, earlier:[Int], later: [Int])? {
        //    # The following ranges are only valid if the minimum hr is 45bpm and
        //    # maximum hr is less than 240bpm, since for the acf of the ideal hr signal
        //    # Npeaks = floor(BPM/minHR) - floor(BPM/maxHR)
        //    # in the search ranges 60*fs/maxHR to 60*fs/minHR samples

        var nPeaks: Int!
        if (hr < 90) {
            nPeaks = 1
        }
        else if (hr < 135) {
            nPeaks = 2
        }
        else if (hr < 180) {
            nPeaks = 3
        }
        else if (hr < 225) {
            nPeaks = 4
        }
        else if (hr <= 240) {
            nPeaks = 5
        }
        else {
            return nil
        }

        // # Added this step because in R, the indexing of an array starts at 1
        // # and so our period of the signal is really actual_lag-1, hence
        // # the correction
        let actualLag = actualLag - 1
        
        var earlier_peak: [Int]
        if (actualLag % 2 == 0) {
            earlier_peak = [actualLag / 2]
        }
        else {
            earlier_peak = [Int(floor(Double(actualLag) / 2)), Int(ceil(Double(actualLag) / 2))]
        }
        earlier_peak = earlier_peak.filter { $0 >= minLag }

        let later_peak: [Int]
        if (nPeaks > 1) {
            // later_peak <- actual_lag*seq(2,Npeaks)
            // later_peak[later_peak>max_lag] <- NA
            later_peak = Array(2...nPeaks).map { $0 * actualLag }.filter { $0 <= maxLag }
        }
        else {
            later_peak = []
        }
        
        // # Correction for R index
        // earlier_peak <- earlier_peak + 1
        // later_peak <- later_peak + 1
        return (nPeaks,
                earlier_peak.map { $0 + 1 },
                later_peak.map { $0 + 1 })
    }
    
    func chunkSamples(_ input: [Double], samplingRate: Double, window: TimeInterval = CRFHeartRateWindowSeconds) -> [[Double]] {
        //    hr.data.filtered.chunks <- hr.data.filtered %>%
        //    dplyr::select(red, green, blue) %>%
        //    na.omit() %>%
        //    lapply(mhealthtools:::window_signal, window_length, window_overlap, 'rectangle')
        var output: [[Double]] = []
        let windowLength = Int(round(window * samplingRate))
        var start: Int = 0
        var end: Int = windowLength
        while end < input.count {
            output.append(Array(input[start..<end]))
            start += Int(round(samplingRate))
            end = start + windowLength
        }
        return output
    }

    ///#' Bandpass and sorted mean filter the given signal
    ///#'
    ///#' @param x A time series numeric data
    ///#' @param sampling_rate The sampling rate (fs) of the signal
    func getFilteredSignal(_ input:[Double], samplingRate: Int, dropSeconds: Int = 0) -> [Double]? {
        //        x[is.na(x)] <- 0
        //        x <- x[round(3*sampling_rate):length(x)]
        //        # Ignore the first 3s
        // - note: syoung 04/16/2019 There is a small round-off error in the sample prefiltering code where
        // the first 3 seconds minus 1 is what should actually be dropped. During task run, this is ignored
        // (because the 3 seconds is removed by checking for the isLensCovered flag), but to match his output
        // it is reproduced here for testing purposes.
        let drop = dropSeconds > 0 ? dropSeconds * samplingRate - 1 : 0
        let x = input.dropFirst(drop).map({ $0.isFinite ? $0 : 0 })
        //    x <- signal::filter(bf_low, x) # lowpass
        //    x <- x[round(sampling_rate):length(x)] # 1s
        let lowpass = Array(passFilter(x, samplingRate: samplingRate, type: .low).dropFirst(samplingRate))
        //    x <- signal::filter(bf_high, x) # highpass
        //    x <- x[round(sampling_rate):length(x)] # 1s @ 60Hz
        let highpass = Array(passFilter(lowpass, samplingRate: samplingRate, type: .high).dropFirst(samplingRate))
        // filter usinng mean centering
        let filtered = meanCenteringFilter(highpass, samplingRate: samplingRate)
        return filtered
    }

    func autocorrelation(_ input: [Double], lagMax: Int = 80) -> [Double] {
        //    x_acf <- rep(0, lag.max+1) # the +1 is because, we will have a 0 lag value also
        //    xl <- length(x) # total no of samples
        //    mx <- mean(x) # average/mean
        //    varx <- sum((x-mx)^2) # Unscaled variance
        //    for(i in seq(0, lag.max)){ # for i=0:lag.max
        //        x_acf[i+1] <- sum( (x[1:(xl-i)]-mx) * (x[(i+1):xl]-mx))/varx // # (Unscaled Co-variance)/(Unscaled variance)
        
        let xl = input.count
        let mx = input.mean()
        let varx: Double = input.reduce(Double(0)) { $0 + ($1 - mx) * ($1 - mx) }
        let x = input.offsetR()
        let range = Array(0...lagMax)
        let x_acf: [Double] = range.map { (i) -> Double in
            let x_left = Array(x[1...(xl-i)])
            let x_right = Array(x[(i+1)...xl])
            let indexes = Array(0..<x_left.count)
            let sum = indexes.reduce(Double(0), { (input, idx) -> Double in
                return input + (x_left[idx] - mx) * (x_right[idx] - mx)
            })
            return sum / varx
        }
        return Array(x_acf)
    }
    
    func meanCenteringFilter(_ input: [Double], samplingRate: Int) -> [Double] {

        let mean_filter_order = meanFilterOrder(for: samplingRate)
        let lowerBounds = (mean_filter_order + 1) / 2
        let upperBounds = input.count - (mean_filter_order - 1) / 2
        let x = input.offsetR()
        
        let range = Array(lowerBounds...upperBounds)
        let y = range.map { (i) -> Double in
            let tempLower: Int = i - (mean_filter_order - 1) / 2
            let tempUpper: Int = i + (mean_filter_order - 1) / 2
            let temp_sequence = x[tempLower...tempUpper]
            let temp_sum = temp_sequence.sum()
            let temp_max = temp_sequence.max()!
            let temp_min = temp_sequence.min()!
            let temp_minus = (temp_sum - temp_max + temp_min) / (Double(mean_filter_order) - 2)
            // # 0.00001 is a small value, ideally this should be machine epsilon
            return ((x[i] - temp_minus) / (temp_max - temp_min + 0.00001))
        }
        return y
    }

    func passFilter(_ input: [Double], samplingRate: Int, type: FilterParameters.FilterType) -> [Double] {
        let paramArray = (type == .low) ? lowPassParameters : highPassParameters
        guard let params = paramArray.filterParams(for: samplingRate) else {
            fatalError("WARNING! Failed to get butterworth filter coeffients for \(samplingRate)")
        }
        
        // insert 0 at the first element to offset the array to the 1 index
        let b = params.b.offsetR()
        let a = params.a.offsetR()
        let x = input.offsetR()

        //    y <- rep(0, xl)
        //    # Create a sequence of 0s of the same length as x
        var y = Array(repeating: Double(0), count: x.count)

        //    # For index i, less than the length of the filter we have
        //    # a[1] = 1, always, as the filter coeffs are normalized
        y[1] = b[1]*x[1]
        y[2] = b[1]*x[2] + b[2]*x[1] - a[2]*y[1]
        y[3] = b[1]*x[3] + b[2]*x[2] + b[3]*x[1] - a[2]*y[2] - a[3]*y[1]
        y[4] = b[1]*x[4] + b[2]*x[3] + b[3]*x[2] + b[4]*x[1] - a[2]*y[3] - a[3]*y[2] - a[4]*y[1]
        y[5] = b[1]*x[5] + b[2]*x[4] + b[3]*x[3] + b[4]*x[2] + b[5]*x[1] - a[2]*y[4] - a[3]*y[3] -
        a[4]*y[2] - a[5]*y[1]
        y[6] = b[1]*x[6] + b[2]*x[5] + b[3]*x[4] + b[4]*x[3] + b[5]*x[2] + b[6]*x[1] - a[2]*y[5] -
        a[3]*y[4] - a[4]*y[3] - a[5]*y[2] - a[6]*y[1]
        y[7] = b[1]*x[7] + b[2]*x[6] + b[3]*x[5] + b[4]*x[4] + b[5]*x[3] + b[6]*x[2] + b[7]*x[1] -
        a[2]*y[6] - a[3]*y[5] - a[4]*y[4] - a[5]*y[3] - a[6]*y[2] - a[7]*y[1]

        //    # For index i, greater than or equal to the length of the filter, we have
        //    for(i in seq(8,length(x))){
        for i in 8..<x.count {
            y[i] = b[1]*x[i] + b[2]*x[i-1] + b[3]*x[i-2] + b[4]*x[i-3] +
                b[5]*x[i-4] + b[6]*x[i-5] + b[7]*x[i-6] + b[8]*x[i-7] -
                a[2]*y[i-1] - a[3]*y[i-2] - a[4]*y[i-3] - a[5]*y[i-4] -
                a[6]*y[i-5] - a[7]*y[i-6] - a[8]*y[i-7]
        }

        return Array(y.dropFirst())
    }

    func meanFilterOrder(for samplingRate: Int) -> Int {
        if (samplingRate <= 32) {
            return 33
        }
        else if (samplingRate <= 18) {
            return 19
        }
        else if (samplingRate <= 15) {
            return 15
        }
        else {
            return 65
        }
    }
}

protocol FilterParams {
    var sampling_rate : Int { get }
}

extension Array where Element : FilterParams {
    
    func filterParams(for sampling_rate: Int) -> Element? {
        return self.first(where: { $0.sampling_rate == sampling_rate })
    }
}

let lowPassParameters : [FilterParameters] = {
    return (try? getParams(FilterParameters.self, from: "lowpass_filter_params")) ?? []
}()

let highPassParameters : [FilterParameters] = {
    return (try? getParams(FilterParameters.self, from: "highpass_filter_params")) ?? []
}()

func getParams<T : Decodable>(_ type: T.Type, from filename: String) throws -> [T] {
    let bundle = Bundle(for: CRFFactory.self)
    guard let url = bundle.url(forResource: filename, withExtension: "csv") else {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "\(filename) not found"))
    }
    let data = try Data(contentsOf: url)
    let decoder = CSVDecoder()
    let params = try decoder.decodeArray(type, from: data)
    return params
}

struct FilterParameters : Codable, FilterParams, Equatable {
    
    enum FilterType : String, Codable {
        case low, high
    }
    
    let filter_type: FilterType
    let sampling_rate: Int
    
    let b1 : Double
    let b2 : Double
    let b3 : Double
    let b4 : Double
    let b5 : Double
    let b6 : Double
    let b7 : Double
    let b8 : Double
    
    var b: [Double] {
        return [b1, b2, b3, b4, b5, b6, b7, b8]
    }
    
    let a1 : Double
    let a2 : Double
    let a3 : Double
    let a4 : Double
    let a5 : Double
    let a6 : Double
    let a7 : Double
    let a8 : Double
    
    var a: [Double] {
        return [a1, a2, a3, a4, a5, a6, a7, a8]
    }
}


// --- Code ported from Matlab

//func maxSplice(_ input: [Double]) -> (maxValue: Double, [Double]) {
//    //% To just remove the repeated part of the autocorr function (since it is even)
//    let (max_val, x_start) = input.seekMax()
//    return (max_val, Array(input[x_start...]))
//}

/// autocorrelation
func xcorr(_ x: [Double]) -> [Double] {
    let xflip = Array(x.reversed())
    return conv(x, xflip)
}

/// convolution
/// https://www.mathworks.com/help/matlab/ref/conv.html#bucr92l-2
enum ConvolutionType { case full, same }
func conv(_ u: [Double], _ v:[Double], _ type: ConvolutionType = .full) -> [Double] {
    switch type {
    case .same:
        return conv(u, v, outputLength: u.count)
    case .full:
        return conv(u, v, outputLength: -1)
    }
}

func conv(_ u: [Double], _ v:[Double], outputLength: Int) -> [Double] {
    let m = u.count
    let n = v.count
    let range = Array(1...(m+n-1))
    let output: [Double] = range.map { (k) -> Double in
        var sum: Double = 0
        for j in max(1, k+1-n)...min(k, m) {
            sum += u[j-1] * v[k-j]
        }
        return sum
    }
    if outputLength > 0 {
        let center = Int(floor(Double(output.count) / 2))
        let half_u = Int(floor(Double(outputLength) / 2))
        let start = center - half_u
        let end = start + outputLength
        return Array(output[start..<end])
    } else {
        return output
    }
}

extension Sequence where Self.Element : Numeric {
    
    /// Sum the elements of the sequence.
    func sum() -> Element {
        return self.reduce(0, +)
    }
}

extension Array where Element : BinaryFloatingPoint {
    
    func offsetR() -> [Element] {
        var result = self
        result.insert(Element(0), at: 0)
        return result
    }
    
    /// Returns the mean value of the elements.
    func mean() -> Element {
        return self.sum() / Element.init(self.count) 
    }
    
    /// Returns the max value and index of that value.
    func seekMax() -> (value: Element, index: Int) {
        let value = self.max()!
        let index = self.index(of: value)!
        return (value, index)
    }
    
    /// Pad the array with zeros before the value.
    func zeroPadBefore(count: Int) -> [Element] {
        var output = Array(repeating: Element(0), count: count)
        output.append(contentsOf: self)
        return output
    }
    
    /// Pad the array with zeros after the value.
    func zeroPadAfter(count: Int) -> [Element] {
        var output = self
        output.append(contentsOf: Array(repeating: Element(0), count: count))
        return output
    }
}
