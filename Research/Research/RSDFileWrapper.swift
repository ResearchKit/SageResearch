//
//  RSDFileWrapper.swift
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct RSDFileWrapper : RawRepresentable, Hashable {
    public typealias RawValue = String
    
    /// The name of the file.
    public let rawValue: String
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: Bundle? = nil
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension RSDFileWrapper : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension RSDFileWrapper : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
        self.factoryBundle = decoder.bundle
    }
}

extension RSDFileWrapper : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension RSDFileWrapper {
    
    var resourceName: String {
        return rawValue
    }
    
    /// Assuming that this file is an image, return the image. This will first look in the asset
    /// catalog and *then* check if the image is in the resource bundle. If the image is a PDF,
    /// it will then attempt to render the image from the PDF to an image of the same size as the
    /// "media" size of the PDF. The logic for inclusion in the asset catalog may change when/if
    /// Apple fixes their caching issues. As of this writing, there is a bug in some versions of
    /// of iOS supported by this framework that causes larger images to crash the application b/c
    /// of low memory and improper release of the cache. syoung 08/01/2019
    ///
    /// - seealso: https://forums.developer.apple.com/thread/18767
    ///
    /// - parameters:
    ///     - bundle: The default bundle to use.
    ///     - defaultExtension: The default extension for the file.
    /// - returns: The image (if found).
    public func fetchImages(from bundle: Bundle? = nil, ofSize size: CGSize = .zero, ofType defaultExtension: String? = nil) -> [RSDImage] {
        if let path = self.imagePath(from: bundle, ofType: defaultExtension),
            let image = RSDImage(contentsOfFile: path) {
            return [image]
        }
        else if let image = namedImage(from: bundle) {
            print("WARNING! Using the image asset catalog can result in a low-memory crash when running on device.")
            return [image]
        }
        else {
            return self.pdfImages(from: bundle, ofSize: size)
        }
    }
    
    private func namedImage(from bundle: Bundle? = nil) -> RSDImage? {
        #if os(watchOS)
        return RSDImage(named: resourceName)
        #elseif os(macOS)
        return RSDImage(named: resourceName)
        #else
        let bundle = resourceBundle(bundle)
        return RSDImage(named: resourceName, in: bundle, compatibleWith: nil)
        #endif
    }
    
    private func pdfImages(from bundle: Bundle?, ofSize size: CGSize) -> [RSDImage] {
        guard let url = self.url(from: bundle, ofType: "pdf") else { return [] }
        return drawPDFfromURL(url: url)
    }
    
    #if os(iOS) || os(tvOS)
    
    private func drawPDFfromURL(url: URL) -> [RSDImage] {
        guard let document = CGPDFDocument(url as CFURL) else { return [] }
        var images = [RSDImage]()
        var pageIndex = 1
        while let img = drawImage(from: document, at: pageIndex) {
            images.append(img)
            pageIndex += 1
        }
        return images
    }
    
    private func drawImage(from document:CGPDFDocument, at pageIndex: Int) -> UIImage? {
        guard let page = document.page(at: pageIndex) else { return nil }
        // TODO: syoung 08/01/2019 Look into rendering at the size requested by the view.
        let scale = UIScreen.main.scale
        let pageRect = page.getBoxRect(.mediaBox).applying(.init(scaleX: scale, y: scale))
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.clear.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: scale, y: -1.0 * scale)
            ctx.cgContext.drawPDFPage(page)
        }
        return img
    }
    
    #else
    
    private func drawPDFfromURL(url: URL) -> [RSDImage] {
        print("WARNING! Drawing an image from a pdf is not supported in watchOS or macOS")
        return []
    }
    
    #endif
    
    private func resourceBundle(_ bundle: Bundle?) -> Bundle {
        return bundle ?? self.factoryBundle ?? Bundle.main
    }
    
    public func imagePath(from bundle: Bundle?, ofType defaultExtension: String?) -> String? {
        let (resource, ext) = self.resource(ofType: defaultExtension ?? "png")
        let scale = Int(UIScreen.main.scale)
        let imageName = "\(resource)@\(scale)x"
        return resourceBundle(bundle).path(forResource: imageName, ofType: ext)
    }
    
    /// Get the path to the resource defined by this file wrapper. This will return `nil` if the
    /// file is part of an asset catalog.
    /// - parameters:
    ///     - bundle: The default bundle to use.
    ///     - defaultExtension: The default extension for the file.
    /// - returns: The fully qualified path if found.
    public func path(from bundle: Bundle?, ofType defaultExtension: String?) -> String? {
        let (resource, ext) = self.resource(ofType: defaultExtension)
        return resourceBundle(bundle).path(forResource: resource, ofType: ext)
    }
    
    /// Get the path to the resource defined by this file wrapper. This will return `nil` if the
    /// file is part of an asset catalog.
    /// - parameters:
    ///     - bundle: The default bundle to use.
    ///     - defaultExtension: The default extension for the file.
    /// - returns: The fully qualified path if found.
    public func url(from bundle: Bundle?, ofType defaultExtension: String?) -> URL? {
        let (resource, ext) = self.resource(ofType: defaultExtension)
        return resourceBundle(bundle).url(forResource: resource, withExtension: ext)
    }
    
    private func resource(ofType defaultExtension: String?) -> (name: String, ext: String?) {
        var resource = resourceName
        var ext = defaultExtension
        let split = resourceName.components(separatedBy: ".")
        if split.count == 2 {
            ext = split.last!
            resource = split.first!
        }
        return (resource, ext)
    }
}
