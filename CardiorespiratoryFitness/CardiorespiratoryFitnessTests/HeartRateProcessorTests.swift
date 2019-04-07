//
//  HeartRateProcessorTests.swift
//  CardiorespiratoryFitnessTests
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

import XCTest
@testable import CardiorespiratoryFitness
 
class HeartRateProcessorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // - note: syoung 04/07/2019 Most of these algorithms are using the incorrect sampling rate because of an
    // error in the R code used to calculate the sampling rate.
    
    func testParams() {
        XCTAssertEqual(highPassParameters.count, 56)
        XCTAssertEqual(lowPassParameters.count, 56)
    }
    
    func compare(_ array1: [Double], _ array2: [Double], accuracy: Double) -> Bool {
        XCTAssertEqual(array1.count, array2.count)
        guard array1.count == array2.count else { return false }
        for (idx, value) in array2.enumerated() {
            XCTAssertEqual(array2[idx], value, accuracy: accuracy)
            guard abs(array2[idx] - value) <= accuracy else { return false }
        }
        return true
    }
    
    func testInvalidSamplingRate() {
        let processor = CRFHeartRateSampleProcessor()
        XCTAssertFalse(processor.isValidSamplingRate(2))
    }
    
    func testLowPassFilterParams() {
        XCTAssertEqual(lowPassParameters.count, 56)

        guard let filter = lowPassParameters.filterParams(for: testData.roundedSamplingRate) else {
            XCTFail("Failed to the the low pass filter parameters")
            return
        }
        
        XCTAssertTrue(compare(filter.a, testData.a_lowpass, accuracy: 0.00000001))
        XCTAssertTrue(compare(filter.b, testData.b_lowpass, accuracy: 0.00000001))
    }
    
    func testHighPassFilterParams() {
        XCTAssertEqual(highPassParameters.count, 56)
        
        guard let filter = highPassParameters.filterParams(for: testData.roundedSamplingRate) else {
            XCTFail("Failed to the the low pass filter parameters")
            return
        }

        XCTAssertTrue(compare(filter.a, testData.a_highpass, accuracy: 0.00000001))
        XCTAssertTrue(compare(filter.b, testData.b_highpass, accuracy: 0.00000001))
    }
    
    func testLowPassFilter() {
        let processor = CRFHeartRateSampleProcessor()
        guard processor.isValidSamplingRate(testData.roundedSamplingRate) else {
            XCTFail("The low pass filter parameters were not parsed. See testLowPassFilterParams()")
            return
        }
        let lowPass = processor.passFilter(testData.input, samplingRate: testData.roundedSamplingRate, type: .low)
        XCTAssertTrue(compare(lowPass, testData.lowpass, accuracy: 0.00000001))
    }
    
    func testHighPassFilter() {
        let processor = CRFHeartRateSampleProcessor()
        guard processor.isValidSamplingRate(testData.roundedSamplingRate) else {
            XCTFail("The low pass filter parameters were not parsed. See testHighPassFilterParams()")
            return
        }
        let highPass = processor.passFilter(testData.input, samplingRate: testData.roundedSamplingRate, type: .high)
        XCTAssertTrue(compare(highPass, testData.highpass, accuracy: 0.00000001))
    }
    
    func testMeanCenteringFilter() {
        let processor = CRFHeartRateSampleProcessor()
        let mcf = processor.meanCenteringFilter(testData.input, samplingRate: testData.roundedSamplingRate)
        XCTAssertTrue(compare(mcf, testData.mcfilter, accuracy: 0.00000001))
    }
    
    func testAutocorrelation() {
        let processor = CRFHeartRateSampleProcessor()
        let acf = processor.autocorrelation(testData.input)
        XCTAssertTrue(compare(acf, testData.acf, accuracy: 0.00000001))
    }
    
    func testCalculateSamplingRate() {
        let processor = CRFHeartRateSampleProcessor()
        let samplingRate = processor.calculateSamplingRate(from: testHRData.hr_data)
        XCTAssertEqual(samplingRate, 59.980, accuracy: 0.001)
    }
    
    func testCalculateSamplingRate_12hz() {
        let processor = CRFHeartRateSampleProcessor()
        let samplingRate = processor.calculateSamplingRate(from: testHRData12hz.hr_data)
        XCTAssertEqual(samplingRate, 12.724, accuracy: 0.001)
    }
    
    func testGetFilteredSignal() {
        let processor = CRFHeartRateSampleProcessor()
        ChannelKeys.allCases.forEach { (key) in
            let input: [Double] = testHRData.hr_data.map {
                switch key {
                case .red:
                    return $0.red
                case .green:
                    return $0.green
                case .blue:
                    return $0.blue
                }
            }
            let expectedOutput: [Double] = testHRData.hr_data_filtered.map { $0[key.stringValue] ?? 0 }
            guard let output = processor.getFilteredSignal(input, samplingRate: testData.roundedSamplingRate, dropSeconds: 3)
                else {
                    XCTFail("Failed to get filtered signal for \(key)")
                    return
            }
            XCTAssertTrue(compare(output, expectedOutput, accuracy: 0.00000001), "\(key)")
        }
    }

    func testChunkedSamples() {
        let processor = CRFHeartRateSampleProcessor()
        let samplingRate = processor.calculateSamplingRate(from: testHRData.hr_data)

        ChannelKeys.allCases.forEach { (key) in
            let input: [Double] = testHRData.hr_data_filtered.map { $0[key.stringValue] ?? 0 }
            let expectedOutput: [[Double]] = testHRData.hrInputChunk(for: key)
            let output = processor.chunkSamples(input, samplingRate: samplingRate)
            XCTAssertEqual(output.count, expectedOutput.count)
            guard output.count == expectedOutput.count else { return }
            for ii in 0..<output.count {
                XCTAssertTrue(compare(output[ii], expectedOutput[ii], accuracy: 0.00000001), "\(key): \(ii)")
            }
        }
    }
    
    func testChunkedSamples_12hz() {
        let processor = CRFHeartRateSampleProcessor()
        let samplingRate = processor.calculateSamplingRate(from: testHRData12hz.hr_data)
        ChannelKeys.allCases.forEach { (key) in
            let input: [Double] = testHRData12hz.hr_data_filtered.map { $0[key.stringValue] ?? 0 }
            let expectedOutput: [[Double]] = testHRData12hz.hrInputChunk(for: key)
            let output = processor.chunkSamples(input, samplingRate: samplingRate)
            XCTAssertEqual(output.count, expectedOutput.count)
            guard output.count == expectedOutput.count else { return }
            for ii in 0..<output.count {
                XCTAssertTrue(compare(output[ii], expectedOutput[ii], accuracy: 0.00000001), "\(key): \(ii)")
            }
        }
    }
    
    func testCalculatedLag() {
        let processor = CRFHeartRateSampleProcessor()
        let minLag = processor.calculateMinLag(samplingRate: testData.samplingRate)
        XCTAssertEqual(minLag, testData.minLag)
        let maxLag = processor.calculateMaxLag(samplingRate: testData.samplingRate)
        XCTAssertEqual(maxLag, testData.maxLag)
    }
    
    func testEstimatedHR_ACF() {
        let processor = CRFHeartRateSampleProcessor()
        let samplingRate = processor.calculateSamplingRate(from: testHRData.hr_data)

        ChannelKeys.allCases.forEach { (key) in
            let key: ChannelKeys = .red
            let inputChunks: [[Double]] = testHRData.hrInputChunk(for: key)
            let expectedOutputs: [[Double]] = testHRData.hrChunkACF(for: key)
            XCTAssertEqual(inputChunks.count, expectedOutputs.count)
            guard inputChunks.count == expectedOutputs.count
                else {
                    XCTFail("The test data is invalid")
                    return
            }
            for ii in 0..<expectedOutputs.count {
                guard let output = processor.preprocessSamples(inputChunks[ii], samplingRate: samplingRate)
                    else {
                        XCTFail("Failed to preprocess the sample chunks. \(key): \(ii)")
                        return
                }
                XCTAssertTrue(compare(Array(output.x.dropFirst()), expectedOutputs[ii], accuracy: 0.00000001), "\(key): \(ii)")
                XCTAssertEqual(output.minLag, testData.minLag, "\(key): \(ii)")
                XCTAssertEqual(output.maxLag, testData.maxLag, "\(key): \(ii)")
                
                // Do not run remaining tests on the data that can't calculate heart rate
                guard ii > 1 else { return }
                
                let bounds = processor.getBounds(y: output.y, samplingRate: testData.samplingRate)
                
                XCTAssertLessThan(bounds.y_max_pos, output.maxLag, "\(key): \(ii)")
                XCTAssertGreaterThan(bounds.y_max_pos, output.minLag, "\(key): \(ii)")
                
                guard let peaks = processor.getAliasingPeakLocation(hr: bounds.hr_initial_guess,
                                                              actualLag: bounds.y_max_pos,
                                                              samplingRate: testData.samplingRate,
                                                              minLag: testData.minLag,
                                                              maxLag: testData.maxLag)
                    else {
                        XCTFail("Failed to get peaks. \(key): \(ii)")
                        return
                }
                
                XCTAssertEqual(peaks.nPeaks, 1, "\(key): \(ii)")
                
            }
        }
    }
    
    func testEstimatedHR_ACF_12hz() {
        let processor = CRFHeartRateSampleProcessor()
        let samplingRate = processor.calculateSamplingRate(from: testHRData12hz.hr_data)

        ChannelKeys.allCases.forEach { (key) in
            let key: ChannelKeys = .red
            let inputChunks: [[Double]] = testHRData12hz.hrInputChunk(for: key)
            let expectedOutputs: [[Double]] = testHRData12hz.hrChunkACF(for: key)
            XCTAssertEqual(inputChunks.count, expectedOutputs.count)
            guard inputChunks.count == expectedOutputs.count
                else {
                    XCTFail("The test data is invalid")
                    return
            }
            for ii in 0..<expectedOutputs.count {
                guard let output = processor.preprocessSamples(inputChunks[ii], samplingRate: samplingRate)
                    else {
                        XCTFail("Failed to preprocess the sample chunks. \(key): \(ii)")
                        return
                }
                XCTAssertTrue(compare(Array(output.x.dropFirst()), expectedOutputs[ii], accuracy: 0.00000001), "\(key): \(ii)")
            }
        }
    }
    
    func testEstimatedHR() {
        let processor = CRFHeartRateSampleProcessor()
        let samplingRate = processor.calculateSamplingRate(from: testHRData.hr_data)

        //ChannelKeys.allCases.forEach { (key) in
        let key: ChannelKeys = .red
            let inputChunks: [[Double]] = testHRData.hrInputChunk(for: key)
            let expectedOutputs: [HRTuple] = testHRData.hr_estimates[key.stringValue]!
            XCTAssertEqual(inputChunks.count, expectedOutputs.count)
            guard inputChunks.count == expectedOutputs.count
                else {
                    XCTFail("The test data is invalid")
                    return
            }
            for ii in 0..<expectedOutputs.count {
            
                let (hr, confidence) = processor.getHR(from: inputChunks[ii], samplingRate: samplingRate)
                if let expectedHR = expectedOutputs[ii].hr,
                    let expectedConfidence = expectedOutputs[ii].confidence {
                    XCTAssertEqual(hr, expectedHR, accuracy: 0.0001, "\(key) \(ii)")
                    XCTAssertEqual(confidence, expectedConfidence, accuracy: 0.0001, "\(key) \(ii)")
                }
                else {
                    XCTAssertEqual(hr, 0, "\(key) \(ii)")
                    XCTAssertEqual(confidence, 0, "\(key) \(ii)")
                }
            }
        //}
    }
}
    
let testData: ProcessorTestData = {
    do {
        let bundle = Bundle(for: HeartRateProcessorTests.self)
        let url = bundle.url(forResource: "io_examples", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let params = try decoder.decode(ProcessorTestData.self, from: data)
        return params
    }
    catch let err {
        fatalError("Cannot decode test data. \(err)")
    }
}()

let testHRData: HRProcessorTestData = {
    do {
        let bundle = Bundle(for: HeartRateProcessorTests.self)
        let url = bundle.url(forResource: "io_examples_whole", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let params = try decoder.decode(HRProcessorTestData.self, from: data)
        return params
    }
    catch let err {
        fatalError("Cannot decode test data. \(err)")
    }
}()

let testHRData12hz: HRProcessorTestData = {
    do {
        let bundle = Bundle(for: HeartRateProcessorTests.self)
        let url = bundle.url(forResource: "io_examples_whole_12hz", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let params = try decoder.decode(HRProcessorTestData.self, from: data)
        return params
    }
    catch let err {
        fatalError("Cannot decode test data. \(err)")
    }
}()

struct ProcessorTestData : Codable {
    
    let input : [Double]
    let lowpass : [Double]
    let highpass : [Double]
    let mcfilter : [Double]
    let acf : [Double]
    let b_lowpass : [Double]
    let a_lowpass : [Double]
    let b_highpass : [Double]
    let a_highpass : [Double]
    let mean_filter_order : [Int]
    let sampling_rate_round : [Int]
    let sampling_rate: [Double]
    let max_hr: [Int]
    let min_hr: [Int]
    let max_lag: [Int]
    let min_lag: [Int]
    
    var samplingRate: Double {
        return sampling_rate.first!
    }
    
    var maxLag: Int {
        return max_lag.first!
    }
    
    var minLag: Int {
        return min_lag.first!
    }
    
    var roundedSamplingRate: Int {
        return sampling_rate_round.first!
    }
}

struct HRProcessorTestData : Decodable {
    
    let hr_data : [TestPixelSample]
    let hr_data_filtered : [[String : Double]]
    let hr_data_filtered_chunked : [String : [[Double]]]
    let hr_data_filtered_chunked_acf : [String : [[Double]]]
    let hr_estimates : [String : [HRTuple]]
    
    // The matrix for this is defined very oddly. It's actually a mapping of the index of each element.
    func hrInputChunk(for key: ChannelKeys) -> [[Double]] {
        let vector = hr_data_filtered_chunked[key.stringValue]!
        return flip(vector)
    }
    
    // The matrix for this is defined very oddly. It's actually a mapping of the index of each element.
    func hrChunkACF(for key: ChannelKeys) -> [[Double]] {
        let vector = hr_data_filtered_chunked_acf[key.stringValue]!
        return flip(vector)
    }
    
    func flip(_ vector: [[Double]]) -> [[Double]] {
        let first = vector[0]
        let ret = Array(0..<first.count).map { (nn) -> [Double] in
            return Array(0..<vector.count).map { (mm) -> Double in
                return vector[mm][nn]
            }
        }
        return ret
    }
}

struct TestPixelSample : Codable, PixelSample {
    private enum CodingKeys : String, CodingKey {
        case presentationTimestamp = "t", _red = "red", _green = "green", _blue = "blue"
    }
    
    let presentationTimestamp: Double
    let _red: Double?
    let _green: Double?
    let _blue: Double?
    
    var red: Double {
        return _red ?? 0
    }
    
    var green: Double {
        return _green ?? 0
    }
    
    var blue: Double {
        return _blue ?? 0
    }
    
    var isCoveringLens: Bool {
        return _red != nil && _green != nil && _blue != nil
    }
}

struct HRTuple : Codable {
    let hr: Double?
    let confidence: Double?
}

enum ChannelKeys : String, CodingKey, CaseIterable {
    case red, green, blue
}
