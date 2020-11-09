//
//  RSDResourceImageDataObject+Platform.swift
//  Research
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

import Foundation
import Research

extension RSDResourceImageDataObject {

    /// Initialize the wrapper with a given image name.
    /// - parameter imageName: The name of the image to be fetched.
    /// - throws: `RSDValidationError.invalidImageName` if the wrapper cannot convert the `imageName` to an
    ///         image. This error will only be thrown if there is **not** a `sharedDelegate`. In that case,
    ///         this initializer will check that the image is either included in the main bundle or in the
    ///         bundle returned by a call to `RSDResourceConfig.resourceBundle()`.
    public init?(imageName: String, bundle: Bundle?) throws {
        try validateImage(imageName: imageName, bundle: bundle)
        self.init(imageName: imageName)
        self.factoryBundle = bundle
        self.packageName = nil
    }
}

fileprivate func validateImage(imageName: String, bundle: Bundle?) throws {
    // Check that the input string can be converted to an image from an embedded resource bundle or that
    // there is a delegate. Otherwise, this is not a valid string and the wrapper doesn't know how to fetch
    // an image with it.
    #if os(watchOS) || os(macOS)
    guard let _ = RSDImage(named: imageName)
        else {
            throw RSDValidationError.invalidImageName("Invalid image name: \(imageName). Cannot use images on the watch that are not included in the main bundle.")
    }
    #else
    guard let _ = RSDImage(named: imageName, in: bundle, compatibleWith: nil)
        else {
            throw RSDValidationError.invalidImageName("Invalid image name: \(imageName)")
    }
    #endif
}
