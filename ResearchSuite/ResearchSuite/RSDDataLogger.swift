//
//  RSDDataLogger.swift
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

/// `RSDDataLogger` is used to write data samples using a custom encoding to a logging file.
/// - note: This class does **not** use a serial queue to process the samples. It is assumed that the
/// recorder that is using this file will handle that implementation.
open class RSDDataLogger {
    
    /// A unique identifier for the logger.
    public let identifier: String
    
    /// The url to the file.
    public let url: URL
    
    /// Open file handle for writing to the logger.
    private let fileHandle: FileHandle
    
    /// Number of samples written to the file.
    public private(set) var sampleCount: Int = 0
    
    /// Default initializer. The initializer will automatically open the file and write the
    /// initial data (if any).
    ///
    /// - parameters:
    ///     - identifier: A unique identifier for the logger.
    ///     - url: The url to the file.
    ///     - initialData: The initial data to write to the file on opening.
    public init(identifier: String, url: URL, initialData: Data?) throws {
        self.identifier = identifier
        self.url = url
        
        let data = initialData ?? Data()
        try data.write(to: url)
        
        self.fileHandle = try FileHandle(forWritingTo: url)
    }
    
    /// Write data to the logger.
    /// - parameter data: The data to add to the logging file.
    /// - throws: Error if writing the data fails because the wasn't enough memory on the device.
    open func write(_ data: Data) throws {
        try RSDExceptionHandler.try {
            self.fileHandle.seekToEndOfFile()
            self.fileHandle.write(data)
        }
        sampleCount += 1
    }
    
    /// Close the file. This will write the end tag for the root element and then close the file handle.
    /// If there is an error thrown by writing the closing tag, then the file handle will be closed and
    /// the error will be rethrown.
    ///
    /// - throws: Error thrown when attempting to write the closing tag.
    open func close() throws {
        self.fileHandle.closeFile()
    }
}

/// `RSDFileResultUtility` is a utility for naming temporary files used to save task results.
public class RSDFileResultUtility {
    
    /// Convenience method for creating a file URL to use as the location to save data.
    ///
    /// This utility will create a directory from the identifier by scrubbing the identifier string of
    /// any non-alphanumeric characters and then using the first 12 characters of the resulting string.
    /// If the resulting string is empty then "temp" will be used. The method then creates the directory
    /// if needed.
    ///
    /// Next, a UUID is created and the first 8 characters of the UUID are used as the filename.
    ///
    /// The purpose of using this method is two-fold. First, it uses a directory that is simplier for
    /// developers to find while developing a recorder. Second, it limits the length of the file path
    /// components to avoid issues with length limits in the stored filename if the name is stored to
    /// a database.
    ///
    /// - parameters:
    ///     - identifier: The identifier string for the step or configuration that will use the file.
    ///     - ext: The file extension.
    ///     - outputDirectory: File URL for the directory in which to store generated data files.
    /// - returns: Scrubbed URL for the given identifier.
    /// - throws: An exception if the file directory cannot be created.
    public static func createFileURL(identifier: String, ext: String, outputDirectory: URL) throws -> URL {
        
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
        let url = dirURL.appendingPathComponent(filename, isDirectory: false).appendingPathExtension(ext)
        
        return url
    }
}
