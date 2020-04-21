//
//  DataArchiveTests.swift
//  Research
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

import XCTest
@testable import Research
import JsonModel

class DataArchiveTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDataArchiver_SingleTask() {
        let taskViewModel = buildTaskViewModel(identifier: "foo")
        do {
            let outputDir = taskViewModel.outputDirectory!
            let asyncResult = try buildFileResult(identifier: "asyncFile", outputDirectory: outputDir)
            taskViewModel.taskResult.appendAsyncResult(with: asyncResult)
            
            // check assumption
            XCTAssertTrue(FileManager.default.fileExists(atPath: outputDir.path))
            
            // add the first collection to the task path
            taskViewModel.taskResult.appendStepHistory(with: RSDResultObject(identifier: "step1"))
            taskViewModel.taskResult.appendStepHistory(with: RSDResultObject(identifier: "step2"))
            taskViewModel.taskResult.appendStepHistory(with: buildCollectionResult(identifier: "collection"))
            taskViewModel.taskResult.appendStepHistory(with: buildSingleAnswerResult(identifier: "single", answer: 5))
            taskViewModel.taskResult.appendStepHistory(with: AnswerResultObject(identifier: "only", value: .integer(7)))
            
            // add the second collection as a subsection
            var sectionResult = RSDTaskResultObject(identifier: "sectionA")
            sectionResult.appendStepHistory(with: RSDResultObject(identifier: "step1"))
            sectionResult.appendStepHistory(with: RSDResultObject(identifier: "step2"))
            sectionResult.appendStepHistory(with: buildCollectionResult(identifier: "collection"))
            sectionResult.appendStepHistory(with: buildSingleAnswerResult(identifier: "single", answer: 3))
            sectionResult.appendStepHistory(with: AnswerResultObject(identifier: "only", value: .integer(9)))
            taskViewModel.taskResult.appendStepHistory(with: sectionResult)

            let manager = TestArchiveManager()
            let archive = TestDataArchive("foo")
            manager.dataArchiverFor[taskViewModel.taskResult.identifier] = archive
            
            let expect = expectation(description: "Archive results \(taskViewModel.identifier)")
            taskViewModel.archiveResults(with: manager) { (err) in
                expect.fulfill()
            }
            waitForExpectations(timeout: 2) { (err) in
                XCTAssertNil(err)
            }
            
            // Check that the file result was deleted
            XCTAssertFalse(FileManager.default.fileExists(atPath: outputDir.path))
            
            // Check that the expected methods were called on the manager
            XCTAssertEqual(manager.encryptAndUpload_dataArchives?.first?.identifier, archive.identifier)
            XCTAssertEqual(manager.encryptAndUpload_taskResult?.identifier, taskViewModel.identifier)
            XCTAssertNil(manager.handleArchiveFailure_error)
            XCTAssertNil(manager.shouldContinueOnFail_error)
            
            XCTAssertEqual(archive.insertedData.count, 3)
            for (manifest, data) in archive.insertedData {
                switch manifest.filename {
                case "asyncFile.txt":
                    XCTAssertEqual(manifest.contentType, "text/plain")
                    XCTAssertEqual(manifest.identifier, "asyncFile")
                    
                case "answers.json":
                    XCTAssertEqual(manifest.contentType, "application/json")
                    if let string = String(data: data, encoding: .utf8) {
                        print(string)
                    }
                    let decoder = RSDFactory.shared.createJSONDecoder()
                    let dictionary = try decoder.decode([String : Int].self, from: data)
                    XCTAssertEqual(dictionary.count, 10)
                    XCTAssertEqual(dictionary["collection_input1"], 1)
                    XCTAssertEqual(dictionary["sectionA_collection_input2"], 2)
                    XCTAssertEqual(dictionary["single"], 5)
                    XCTAssertEqual(dictionary["sectionA_single"], 3)
                    XCTAssertEqual(dictionary["only"], 7)
                    XCTAssertEqual(dictionary["sectionA_only"], 9)

                case "taskResult.json":
                    XCTAssertEqual(manifest.contentType, "application/json")
                
                default:
                    XCTFail("Manifest filename unexpected: \(manifest.filename)")
                }
            }
        
        } catch let err {
            XCTFail("Failed unexpectedly: \(err)")
            return
        }
    }
    
    func testDataArchiver_ComboTask() {
        let taskViewModel = buildTaskViewModel(identifier: "foo")
        do {
            let outputDir = taskViewModel.outputDirectory!
            let asyncResult = try buildFileResult(identifier: "asyncFile", outputDirectory: outputDir)
            taskViewModel.taskResult.appendAsyncResult(with: asyncResult)
            
            // check assumption
            XCTAssertTrue(FileManager.default.fileExists(atPath: outputDir.path))
            
            // add the first collection to the task path
            taskViewModel.taskResult.appendStepHistory(with: RSDResultObject(identifier: "step1"))
            taskViewModel.taskResult.appendStepHistory(with: RSDResultObject(identifier: "step2"))
            taskViewModel.taskResult.appendStepHistory(with: buildCollectionResult(identifier: "collection"))
            
            // add the second collection as a subsection
            var sectionResult = RSDTaskResultObject(identifier: "sectionA")
            sectionResult.appendStepHistory(with: RSDResultObject(identifier: "step1"))
            sectionResult.appendStepHistory(with: RSDResultObject(identifier: "step2"))
            sectionResult.appendStepHistory(with: buildCollectionResult(identifier: "collection"))
            taskViewModel.taskResult.appendStepHistory(with: sectionResult)
            
            let manager = TestArchiveManager()
            let mainArchive = TestDataArchive("foo")
            let subArchive = TestDataArchive("sectionA")
            manager.dataArchiverFor[taskViewModel.taskResult.identifier] = mainArchive
            manager.dataArchiverFor["sectionA"] = subArchive
            
            let expect = expectation(description: "Archive results \(taskViewModel.identifier)")
            taskViewModel.archiveResults(with: manager) { (err) in
                expect.fulfill()
            }
            waitForExpectations(timeout: 2) { (err) in
                XCTAssertNil(err)
            }
            
            // Check that the file result was deleted
            XCTAssertFalse(FileManager.default.fileExists(atPath: outputDir.path))
            
            // Check that the expected methods were called on the manager
            XCTAssertEqual(manager.encryptAndUpload_dataArchives?.first?.identifier, mainArchive.identifier)
            XCTAssertEqual(manager.encryptAndUpload_dataArchives?.last?.identifier, subArchive.identifier)
            XCTAssertEqual(manager.encryptAndUpload_taskResult?.identifier, taskViewModel.identifier)
            XCTAssertNil(manager.handleArchiveFailure_error)
            XCTAssertNil(manager.shouldContinueOnFail_error)
            
            XCTAssertEqual(mainArchive.insertedData.count, 3)
            XCTAssertEqual(subArchive.insertedData.count, 2)
            
            for archive in [mainArchive, subArchive] {
                for (manifest, data) in archive.insertedData {
                    switch manifest.filename {
                    case "asyncFile.txt":
                        XCTAssertEqual(manifest.contentType, "text/plain")
                        XCTAssertEqual(manifest.identifier, "asyncFile")
                        
                    case "answers.json":
                        XCTAssertEqual(manifest.contentType, "application/json")
                        if let string = String(data: data, encoding: .utf8) {
                            print(string)
                        }
                        let decoder = RSDFactory.shared.createJSONDecoder()
                        let dictionary = try decoder.decode([String : Int].self, from: data)
                        XCTAssertEqual(dictionary.count, 3)
                        XCTAssertEqual(dictionary["collection_input1"], 1)
                        
                    case "taskResult.json":
                        XCTAssertEqual(manifest.contentType, "application/json")
                        
                    default:
                        XCTFail("Manifest filename unexpected: \(manifest.filename)")
                    }
                }
            }
            
            
            
            
        } catch let err {
            XCTFail("Failed unexpectedly: \(err)")
            return
        }
    }
    
    // Helper method
    
    func buildTaskViewModel(identifier: String) -> RSDTaskViewModel {
        let task = AssessmentTaskObject(identifier: identifier, steps: [])
        return RSDTaskViewModel(task: task)
    }
    
    func buildFileResult(identifier: String, outputDirectory: URL) throws -> RSDFileResultObject {

        let url = try RSDFileResultUtility.createFileURL(identifier: identifier, ext: "txt", outputDirectory: outputDirectory)
        let uuid = UUID().uuidString
        try uuid.write(to: url, atomically: true, encoding: .utf8)
        
        var fileResult = RSDFileResultObject(identifier: identifier)
        fileResult.contentType = "text/plain"
        fileResult.url = url
        return fileResult
    }
    
    func buildCollectionResult(identifier: String) -> RSDCollectionResultObject {
        var collectionResult = RSDCollectionResultObject(identifier: identifier)
        for ii in 1...3 {
            collectionResult.appendInputResults(with: AnswerResultObject(identifier: "input\(ii)", value: .integer(ii)))
        }
        return collectionResult
    }
    
    func buildSingleAnswerResult(identifier: String, answer: Int) -> RSDCollectionResultObject {
        var collectionResult = RSDCollectionResultObject(identifier: identifier)
        collectionResult.appendInputResults(with: AnswerResultObject(identifier: identifier, value: .integer(answer)))
        return collectionResult
    }
}

class TestArchiveManager: NSObject, RSDDataArchiveManager {
    
    var dataArchiverFor: [String : TestDataArchive] = [:]
    
    var shouldContinueOnFail_return: Bool = false
    var shouldContinueOnFail_archive: RSDDataArchive?
    var shouldContinueOnFail_error: Error?
    
    var encryptAndUpload_taskResult: RSDTaskResult?
    var encryptAndUpload_dataArchives: [RSDDataArchive]?
    
    var handleArchiveFailure_taskResult: RSDTaskResult?
    var handleArchiveFailure_error: Error?
    
    func shouldContinueOnFail(for archive: RSDDataArchive, error: Error) -> Bool {
        shouldContinueOnFail_archive = archive
        shouldContinueOnFail_error = error
        return shouldContinueOnFail_return
    }
    
    func dataArchiver(for taskResult: RSDTaskResult, scheduleIdentifier: String?, currentArchive: RSDDataArchive?) -> RSDDataArchive? {
        let archive = dataArchiverFor[taskResult.identifier]
        archive?.scheduleIdentifier = scheduleIdentifier
        return archive ?? currentArchive
    }
    
    func encryptAndUpload(taskResult: RSDTaskResult, dataArchives: [RSDDataArchive], completion: @escaping (() -> Void)) {
        encryptAndUpload_taskResult = taskResult
        encryptAndUpload_dataArchives = dataArchives
        DispatchQueue.main.async {
            completion()
        }
    }
    
    func handleArchiveFailure(taskResult: RSDTaskResult, error: Error, completion: @escaping (() -> Void)) {
        handleArchiveFailure_taskResult = taskResult
        handleArchiveFailure_error = error
        DispatchQueue.main.async {
            completion()
        }
    }
}

class TestDataArchive: NSObject, RSDDataArchive {

    let identifier: String
    var scheduleIdentifier: String?
    
    init(_ identifier: String, scheduleIdentifier: String? = nil) {
        self.identifier = identifier
        self.scheduleIdentifier = scheduleIdentifier
        super.init()
    }
    
    var shouldInsert: [RSDReservedFilename] = [.answers, .taskResult, .metadata]
    var insertedData: [(RSDFileManifest, Data)] = []
    var metadata: RSDTaskMetadata?
    
    func shouldInsertData(for filename: RSDReservedFilename) -> Bool {
        return shouldInsert.contains(filename)
    }
    
    func insertDataIntoArchive(_ data: Data, manifest: RSDFileManifest) {
        insertedData.append((manifest, data))
    }
    
    func completeArchive(with metadata: RSDTaskMetadata) throws {
        self.metadata = metadata
    }
    
    func archivableData(for result: RSDResult, sectionIdentifier: String?, stepPath: String?) -> RSDArchivable? {
        return result as? RSDArchivable
    }
}
