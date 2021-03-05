//
//  main.swift
//  rsd-migration-tool
//
//  Copyright © 2021 Sage Bionetworks. All rights reserved.
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

func run() {
    
    let arguments = CommandLine.arguments
    var dirpath = (arguments.count <= 1) ? FileManager.default.currentDirectoryPath : arguments[1]
    if dirpath.hasPrefix("~/") {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        dirpath = String(dirpath.replacingOccurrences(of: "~/", with: homeDir.absoluteString))
    }
    guard let url = URL(string: dirpath) else {
        print("Could not create URL from \(dirpath)")
        return
    }
    print("migrating .swift files in \(url)")
    
    do {
        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
        let enumerator = FileManager.default.enumerator(at: url,
                                includingPropertiesForKeys: resourceKeys,
                                                   options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                            print("directoryEnumerator error at \(url): ", error)
                                                            return true
        })!

        for case let fileURL as URL in enumerator {
            let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
            if !resourceValues.isDirectory!, fileURL.pathExtension == "swift" {
                try migrateFile(fileURL: fileURL)
            }
        }
    } catch {
        print(error)
    }
}

enum Library : String, CaseIterable {
    case jsonModel = "JsonModel"
}

struct Keyword {
    let library: Library
    let find: String
    let replace: String?
}

protocol TypeNameChange {
    var library: Library { get }
    var originalTypeName: String { get }
    var replacementTypeName: String { get }
}

extension TypeNameChange {
    func replacingTypeNames(_ line: String) -> String {
        var ret = line
        ret = ret.replacingOccurrences(of: "\(originalTypeName) ", with: "\(replacementTypeName) ")
        ret = ret.replacingOccurrences(of: "\(originalTypeName)?", with: "\(replacementTypeName)?")
        ret = ret.replacingOccurrences(of: "\(originalTypeName)!", with: "\(replacementTypeName)!")
        ret = ret.replacingOccurrences(of: "\(originalTypeName))", with: "\(replacementTypeName))")
        ret = ret.replacingOccurrences(of: "\(originalTypeName),", with: "\(replacementTypeName),")
        ret = ret.replacingOccurrences(of: "\(originalTypeName).", with: "\(replacementTypeName).")
        ret = ret.replacingOccurrences(of: "[\(originalTypeName)]", with: "[\(replacementTypeName)]")
        ret = ret.replacingOccurrences(of: "-> \(originalTypeName)", with: "-> \(replacementTypeName)")
        return ret
    }
}

struct ClassNameChange : TypeNameChange {
    let library: Library
    let originalTypeName: String
    let replacementTypeName: String
}

struct VariableNameChange : TypeNameChange {
    let library: Library
    let originalTypeName: String
    let replacementTypeName: String
    let originalVarName: String
    let replacementVarName: String
    
    func replacingNames(_ line: String) -> String {
        var ret = line
        ret = ret.replacingOccurrences(of: "var \(originalVarName): \(originalTypeName)", with: "var \(replacementVarName): \(replacementTypeName)")
        ret = ret.replacingOccurrences(of: "let \(originalVarName): \(originalTypeName)", with: "let \(replacementVarName): \(replacementTypeName)")
        ret = ret.replacingOccurrences(of: "let \(originalVarName): \(originalTypeName)", with: "let \(replacementVarName): \(replacementTypeName)")
        ret = ret.replacingOccurrences(of: "decode(\(originalTypeName).self, forKey: .\(originalVarName))", with: "decode(\(replacementTypeName).self, forKey: .\(replacementVarName))")
        ret = ret.replacingOccurrences(of: "\(originalVarName), forKey: .\(originalVarName))", with: "\(replacementVarName), forKey: .\(replacementVarName))")
        ret = ret.replacingOccurrences(of: "self.\(originalVarName) =", with: "self.\(replacementVarName) =")
        ret = ret.replacingOccurrences(of: ".\(originalVarName)", with: ".\(replacementVarName)")
        return self.replacingTypeNames(ret)
    }
}

let importLines = [
    "import Foundation",
    "import UIKit",
    "import XCTest",
    "import Research",
    "import ResearchUI",
]
let keywords = [
    Keyword(library: .jsonModel, find: "AnswerResult", replace: nil),
    Keyword(library: .jsonModel, find: "AnswerType", replace: nil),
    Keyword(library: .jsonModel, find: "AnswerFinder", replace: nil),
    Keyword(library: .jsonModel, find: "CollectionResult", replace: nil),
    Keyword(library: .jsonModel, find: "inputResults", replace: "children"),
]

let classChanges = [
    ClassNameChange(library: .jsonModel, originalTypeName: "RSDResult", replacementTypeName: "ResultData"),
    ClassNameChange(library: .jsonModel, originalTypeName: "RSDFileResult", replacementTypeName: "FileResult"),
    ClassNameChange(library: .jsonModel, originalTypeName: "RSDFileResultObject", replacementTypeName: "FileResultObject"),
    ClassNameChange(library: .jsonModel, originalTypeName: "RSDErrorResult", replacementTypeName: "RSDErrorResult"),
    ClassNameChange(library: .jsonModel, originalTypeName: "RSDErrorResultObject", replacementTypeName: "RSDErrorResultObject"),
]

let varChanges = [
    VariableNameChange(library: .jsonModel, originalTypeName: "RSDResultType", replacementTypeName: "SerializableResultType", originalVarName: "type", replacementVarName: "serializableType"),
    VariableNameChange(library: .jsonModel, originalTypeName: "[RSDResult]", replacementTypeName: "[ResultData]", originalVarName: "inputResults", replacementVarName: "children")
]


func migrateFile(fileURL: URL) throws {
    guard fileURL.pathExtension == "swift", fileURL.lastPathComponent != "main.swift" else { return }
    let currentCode = try String(contentsOf:fileURL, encoding: String.Encoding.utf8)

    var lines = currentCode.components(separatedBy: .newlines)
    var importIdx: Int?
    var hasImport = Set<Library>()
    var needsImport = Set<Library>()
    
    varChanges.forEach { (change) in
        // Look for an extension file and replace the original class name with the new one.
        if currentCode.contains("extension \(change.originalTypeName)") {
            needsImport.insert(change.library)
            lines.enumerated().forEach { (index, line) in
                
                if line.contains("static let") {
                    lines[index] = line.replacingOccurrences(of: ": \(change.originalTypeName) =", with: ": \(change.replacementTypeName) =")
                }
                else {
                    lines[index] = line.replacingOccurrences(of: "extension \(change.originalTypeName)", with: "extension \(change.replacementTypeName)")
                }
            }
        }
        // Look for the ivar and replace with the new one.
        if currentCode.contains("var \(change.originalVarName): \(change.originalTypeName)") ||
            currentCode.contains("let \(change.originalVarName): \(change.originalTypeName)") {
            needsImport.insert(change.library)
            var insideEnum: Bool = false
            lines.enumerated().forEach { (index, line) in
                if line.contains("enum"), line.contains("CodingKey") {
                    insideEnum = true
                }
                else if insideEnum {
                    insideEnum = !line.contains("}")
                    if line.contains(" \(change.originalVarName) =") {
                        lines[index] = line.replacingOccurrences(of: " \(change.originalVarName) =",
                                                                 with: " \(change.replacementVarName) =")
                    }
                    else {
                        lines[index] = line.replacingOccurrences(of: " \(change.originalVarName)",
                                                                 with: " \(change.replacementVarName) = \"\(change.originalVarName)\"")
                    }
                }
                else if line.contains(change.originalVarName) || line.contains(change.originalTypeName) {
                    lines[index] = change.replacingNames(line)
                }
            }
        }
    }
    
    lines.enumerated().forEach { (index, line) in
        if importLines.contains(line) {
            importIdx = index
        }
        Library.allCases.forEach {
            if line == "import \($0.rawValue)" {
                hasImport.insert($0)
            }
        }
        keywords.forEach { keyword in
            guard line.contains(keyword.find) else { return }
            needsImport.insert(keyword.library)
            if let replace = keyword.replace {
                lines[index] = lines[index].replacingOccurrences(of: keyword.find, with: replace)
            }
        }
        classChanges.forEach { change in
            guard line.contains(change.originalTypeName) else { return }
            lines[index] = change.replacingTypeNames(lines[index])
        }
        if line.contains("ResultObject : ") &&
            (line.contains("struct") || line.contains("class")) &&
            !line.contains("ResultObject : SerializableResultData, ") {
            lines[index] = lines[index].replacingOccurrences(of: "ResultObject : ", with: "ResultObject : SerializableResultData, ")
        }
    }

    guard needsImport.count > 0 else { return }

    needsImport.forEach { library in
        guard !hasImport.contains(library), let idx = importIdx else { return }
        lines.insert("import \(library.rawValue)", at: idx)
        importIdx = idx + 1
    }
    
    let data = String(lines.joined(separator: "\n")).data(using: .utf8)!
    let tempURL = fileURL.appendingPathExtension("bk")
    try data.write(to: tempURL)
    try FileManager.default.removeItem(at: fileURL)
    try FileManager.default.moveItem(at: tempURL, to: fileURL)
}

run()
