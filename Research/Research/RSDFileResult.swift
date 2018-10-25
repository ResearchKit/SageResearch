//
//  RSDFileResult.swift
//  Research
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


/// `RSDFileResult` is a result that holds a pointer to a file url.
public protocol RSDFileResult : RSDResult, RSDArchivable {
    
    /// The URL with the full path to the file-based result. This should *not*
    /// be encoded in the file result if the results are encoded and uploaded
    /// to a server. This is included for use in local file system management
    /// **only**.
    ///
    /// - note: It is the responsibility of the developer to ensure that the
    /// participant's private data is managed securely.
    var url: URL? { get set }
    
    /// The relative path to the file-based result. This should be the relative path
    /// to the file within the `outputDirectory` of the associated `RSDTaskViewModel`.
    var relativePath: String? { get }
    
    /// The MIME content type of the result.
    /// - example: `"application/json"`
    var contentType: String? { get }
    
    /// The system clock uptime when the recorder was started (if applicable).
    var startUptime: TimeInterval? { get }
}

extension RSDFileResult {
    
    /// Build the archiveable or uploadable data for this result.
    public func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)? {
        guard let filename = self.relativePath, let url = self.url else { return nil }
        let manifest = RSDFileManifest(filename: filename, timestamp: self.startDate, contentType: self.contentType, identifier: self.identifier, stepPath: stepPath)
        let data = try Data(contentsOf: url)
        return (manifest, data)
    }
}
