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
    func getHR(from input: [Double], samplingRate: Double) -> (heartRate: Double, confidence: Double) {

        guard let (x, y, minLag, maxLag) = preprocessSamples(input, samplingRate: samplingRate)
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
            //    peak_pos_thresholding_result <- (y[aliasedPeak$earlier_peak]-y_min) > 0.7*(y_max-y_min)
            //    # Check which of the earlier peak(s) satisfy the threshold
            let peak_pos = aliasedPeak.earlier.filter {
                (y[$0] - y_min) > 0.7 * (y_max - y_min)
            }
            
            // peak_pos_thresholding_result <- (y[aliasedPeak$earlier_peak]-y_min) > 0.7*(y_max-y_min)
            // # Check which of the earlier peak(s) satisfy the threshold
            // let peak_pos_thresholding_result: [Bool] = aliasedPeak.earlier.map { (y[$0] - y_min) > 0.7 * (y_max - y_min) }
            
            // peak_pos <- aliasedPeak$earlier_peak[peak_pos_thresholding_result]
            // # Subset to those earlier peak(s) that satisfy the thresholding criterion above
            
            //    # Subset to those earlier peak(s) that satisfy the thresholding criterion above
            if peak_pos.count > 0 {

                var hr_vec = peak_pos.map { (60 * samplingRate) / Double($0) }
                // # Estimate heartrates for each of the peaks that satisfy the thresholding criterion
                hr_vec.append(
                    hr_initial_guess * Double(aliasedPeak.nPeaks + 1) / Double(aliasedPeak.nPeaks)
                )
                hr = hr_vec.mean()
                
                //          # Estimate the heartrate based on our initial guess, Npeaks and the estimated heartrates of the
                //          # peaks that satisfy the threshold
                //
                //          confidence <- mean(y[peak_pos]-y_min)/(max(x)-min(x))
                confidence = peak_pos.map({ y[$0] - y_min }).mean() / (x.max()! - x.min()!)
                //          # Estimate the confidence based on the peaks that satisfy the threshold
                //
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
        let hr_initial_guess = (60.0 * samplingRate) / Double(y_max_pos)
        
        return (y_max, y_max_pos, y_min, hr_initial_guess)
    }
    
    
    func getAliasingPeakLocation(hr: Double, actualLag: Int?, samplingRate: Double, minLag: Int, maxLag: Int) -> (nPeaks: Int, earlier:[Int], later: [Int])? {
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
        
        let actualLag = actualLag ?? Int(ceil(Double(samplingRate * 60) / hr + 1.0))
        
        var earlier_peak: [Int]
        if (actualLag % 2 == 0) {
            earlier_peak = [actualLag / 2]
        }
        else {
            earlier_peak = [Int(floor(Double(actualLag) / 2)), Int(ceil(Double(actualLag) / 2))]
        }
        earlier_peak = earlier_peak.filter { $0 >= minLag }

        var later_peak: [Int]
        if (nPeaks > 1) {
            later_peak = Array(2...nPeaks).map { $0 * actualLag }.filter { $0 <= maxLag }
        }
        else {
            later_peak = []
        }

        return (nPeaks, earlier_peak, later_peak)
    }
    
    func chunkSamples(_ input: [Double], samplingRate: Double) -> [[Double]] {
        //    hr.data.filtered.chunks <- hr.data.filtered %>%
        //    dplyr::select(red, green, blue) %>%
        //    na.omit() %>%
        //    lapply(mhealthtools:::window_signal, window_length, window_overlap, 'rectangle')
        var output: [[Double]] = []
        let windowLength = Int(round(CRFHeartRateWindowSeconds * samplingRate))
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
        let drop = dropSeconds > 0 ? dropSeconds * samplingRate - 1 : 0
        let x = input.dropFirst(drop).map({ $0.isFinite ? $0 : 0 })
        //    x <- signal::filter(bf_low, x) # lowpass
        //    x <- x[round(sampling_rate):length(x)] # 1s
        let lowpass = Array(passFilter(x, samplingRate: samplingRate, type: .low).dropFirst(samplingRate - 1))
        //    x <- signal::filter(bf_high, x) # highpass
        //    x <- x[round(sampling_rate):length(x)] # 1s @ 60Hz
        let highpass = Array(passFilter(lowpass, samplingRate: samplingRate, type: .high).dropFirst(samplingRate - 1))
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
        let range = Array(0...(lagMax+1))
        let x_acf: [Double] = range.map { (i) -> Double in
            let x_left = Array(x[1...(xl-i)])
            let x_right = Array(x[(i+1)...xl])
            let sum = x_left.enumerated().reduce(Double(0), {
                return $0 + ($1.element - mx) * (x_right[$1.offset] - mx)
            })
            return sum / varx
        }
        return Array(x_acf.dropFirst())
    }

    func meanCenteringFilter(_ input: [Double], samplingRate: Int) -> [Double] {
        // insert 0 at the first element to offset the array to the 1 index
        let x = input.offsetR()
        
        let mean_filter_order = meanFilterOrder(for: samplingRate)
        var y = Array(repeating: Double(0), count: x.count)
        let lowerBounds = (mean_filter_order + 1) / 2
        let upperBounds = x.count - (mean_filter_order - 1) / 2
        
        for i in lowerBounds..<upperBounds {
            let tempLower: Int = i - (mean_filter_order - 1) / 2
            let tempUpper: Int = i + (mean_filter_order - 1) / 2
            let temp_sequence = x[tempLower..<tempUpper]
            let temp_sum = temp_sequence.sum()
            let temp_max = temp_sequence.max()!
            let temp_min = temp_sequence.min()!
            let temp_minus = (temp_sum - temp_max + temp_min) / (Double(mean_filter_order) - 2)
            // # 0.00001 is a small value, ideally this should be machine epsilon
            y[i] = ((x[i] - temp_minus) / (temp_max - temp_min + 0.00001))
        }
        y = Array(y[lowerBounds..<upperBounds])
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

/// channel, 60fps, 10sec window
func findHeartRateValues(with channel:[Double]) -> [(heartRate: Double, confidence: Double)] {
    let nframes = Int(floor(Double(channel.count) / (Double(window_len)/2)) - 1)
    guard nframes >= 1 else { return [] }
    var output: [(Double, Double)] = []
    for frame_no in 1...nframes {
        let lower = (1 + ((frame_no - 1) * window_len / 2)) - 1
        let upper = ((frame_no + 1) * window_len / 2) - 1
        let currframe = Array(channel[lower...upper])
        output.append(calculateHeartRate(currframe))
    }
    return output
}

/// For a given window return the calculated heart rate and confidence.
/// - note: The calculated heart rate is rounded.
func calculateHeartRate(_ input: [Double]) -> (heartRate: Double, confidence: Double) {

    //% Preprocess and find the autocorrelation function
    let filteredValues = bandpassFiltered(input)
    let xCorrValues = xcorr(filteredValues)
    
    //% To just remove the repeated part of the autocorr function (since it is even)
    let (max_val, x) = maxSplice(xCorrValues)
    
    //% HR ranges from 40-200 BPM, so consider only that part of the autocorr
    //% function
    let lower = Int(round(60 * fs / 200))
    let upper = Int(round(60 * fs / 40))
    let (val, pos) = x.zeroReplace(lower-1, upper-1).seekMax()
    return (round(60 * fs / Double(pos + 1)), val / max_val)
}

func maxSplice(_ input: [Double]) -> (maxValue: Double, [Double]) {
    //% To just remove the repeated part of the autocorr function (since it is even)
    let (max_val, x_start) = input.seekMax()
    return (max_val, Array(input[x_start...]))
}

func bandpassFiltered(_ input: [Double]) -> [Double] {
    
    // % Setting no. of samples as per a max HR of 220 BPM
    let nsamples = Int(round(60 * fs / 220))
    
    // % b1 = fir1(128,[1/30, 25/30], 'bandpass');
    let b1: [Double] = [-0.000506610984132016,0.000281340196104213,-0.000453477478785663,0.000175433848479960,5.78571000126717e-19,-0.000200178238070410,0.000588479261901569,-0.000412615808534457,0.000832401037231464,-4.84818239396100e-19,0.000465554741153073,0.00102165166976478,-0.000118534274769341,0.00192609062899124,-2.40024436102973e-18,0.00182952606970045,0.00135480554590726,0.000748599044261129,0.00319643179850945,-2.30788276369201e-19,0.00382994518525259,0.00107470141262219,0.00233017559097417,0.00376919225339987,-8.21109764793137e-18,0.00568709829032464,-0.000418547259970266,0.00430878547299781,0.00234096774958672,-1.06597329751523e-17,0.00589948032626289,-0.00345001874823703,0.00577085280898743,-0.00228532700432350,-3.81044085438483e-18,0.00263801974428747,-0.00769131382422690,0.00531148463293734,-0.0104990208677403,1.62815935886881e-17,-0.00558417076326117,-0.0119241848598587,0.00134611898423683,-0.0212997771796790,-2.07091826506435e-17,-0.0192845505914200,-0.0139952617851127,-0.00760318790070690,-0.0320397640632609,-3.05719612807051e-18,-0.0378997870775431,-0.0106518977344771,-0.0232807805994706,-0.0382418951609459,1.64113172833343e-17,-0.0611787321852445,0.00471988055056295,-0.0517540592057603,-0.0305770938728010,3.42293636763843e-17,-0.100426633129967,0.0729786483544900,-0.170609488045242,0.125861208906484,0.800308136102957,0.125861208906484,-0.170609488045242,0.0729786483544900,-0.100426633129967,3.42293636763843e-17,-0.0305770938728010,-0.0517540592057603,0.00471988055056295,-0.0611787321852445,1.64113172833343e-17,-0.0382418951609459,-0.0232807805994706,-0.0106518977344771,-0.0378997870775431,-3.05719612807051e-18,-0.0320397640632609,-0.00760318790070690,-0.0139952617851127,-0.0192845505914200,-2.07091826506435e-17,-0.0212997771796790,0.00134611898423683,-0.0119241848598587,-0.00558417076326117,1.62815935886881e-17,-0.0104990208677403,0.00531148463293734,-0.00769131382422690,0.00263801974428747,-3.81044085438483e-18,-0.00228532700432350,0.00577085280898743,-0.00345001874823703,0.00589948032626289,-1.06597329751523e-17,0.00234096774958672,0.00430878547299781,-0.000418547259970266,0.00568709829032464,-8.21109764793137e-18,0.00376919225339987,0.00233017559097417,0.00107470141262219,0.00382994518525259,-2.30788276369201e-19,0.00319643179850945,0.000748599044261129,0.00135480554590726,0.00182952606970045,-2.40024436102973e-18,0.00192609062899124,-0.000118534274769341,0.00102165166976478,0.000465554741153073,-4.84818239396100e-19,0.000832401037231464,-0.000412615808534457,0.000588479261901569,-0.000200178238070410,5.78571000126717e-19,0.000175433848479960,-0.000453477478785663,0.000281340196104213,-0.000506610984132016]
    
    // Normalize the input
    let meanValue = input.mean()
    let normalizedValues = input.map { ($0 - meanValue) }
    
    //% Preprocess and find the autocorrelation function
    return meanfilter(normalizedValues, 2*nsamples+1, b1)
}

/// Mean filter which emphasizes the maxima in a specified window length (n),
/// but de-emphasizes everything else in that window
func meanfilter(_ input: [Double], _ n: Int, _ b1: [Double]) -> [Double] {
    let x = conv(input, b1, .same).centerSplice(65)
    var output: [Double] = x
    for nn in ((n+1)/2)...(x.count-(n-1)/2) {
        let lower = (nn - (n-1)/2) - 1
        let upper = (nn + (n-1)/2) - 1
        let currwin = x[lower...upper].sorted()
        output[nn-1] = x[nn-1] - ((currwin.sum() - currwin.max()!) / Double(n - 1))
    }
    return output
}

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
    
    /// Replace the elements of the array with the given number of zeros on each side.
    func zeroReplace(_ lowerBounds: Int, _ upperBounds: Int) -> [Element] {
        var y = Array(repeating: Element(0), count: lowerBounds)
        y.append(contentsOf: self[lowerBounds...upperBounds])
        return y
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
    
    /// Return the center of the range minus the ends to endCount.
    func centerSplice(_ endCount: Int) -> [Element] {
        return Array(self[(endCount-1)..<(self.count-endCount)])
    }
}
