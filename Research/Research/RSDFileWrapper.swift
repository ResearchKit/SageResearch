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
    
    /// Assuming that this file is an image, return the image. This will first look in the file
    /// system for the bundle and *then* check if the image is in the asset catalog. If this method
    /// is used, it is assumed that the image *should* be in a file directory and *not* be in the
    /// asset catalog. It will print a warning. The logic for inclusion in the asset catalog may
    /// change when/if Apple fixes their caching issues. syoung 07/16/2019
    ///
    /// - seealso: https://forums.developer.apple.com/thread/18767
    ///
    /// - parameters:
    ///     - bundle: The default bundle to use.
    ///     - defaultExtension: The default extension for the file.
    /// - returns: The image (if found)
    public func fetchImages(from bundle: Bundle? = nil, ofSize size: CGSize = .zero, ofType defaultExtension: String? = nil) -> [RSDImage] {
        if let image = namedImage(from: bundle) {
            print("WARNING! Using the image asset catalog can result in a low-memory crash when running on device.")
            return [image]
        }
        else if let path = self.path(from: bundle, ofType: defaultExtension),
            let image = RSDImage(contentsOfFile: path) {
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
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.clear.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
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

//+(UIImage *) imageWithPDFURL:(NSURL *)URL atHeight:(CGFloat)height atPage:(NSUInteger)page
//{
//    if ( URL == nil )
//    return nil;
//
//    CGRect mediaRect = [ PDFView mediaRectForURL:URL atPage:page ];
//    CGFloat aspectRatio = mediaRect.size.width / mediaRect.size.height;
//
//    CGSize size = CGSizeMake( ceil( height * aspectRatio ), height );
//
//    return [ UIImage imageWithPDFURL:URL atSize:size atPage:page ];
//}
//
//+(UIImage *) imageWithPDFURL:(NSURL *)URL atHeight:(CGFloat)height
//{
//    return [ UIImage imageWithPDFURL:URL atHeight:height atPage:1 ];
//}
//
//+(UIImage *) originalSizeImageWithPDFURL:(NSURL *)URL atPage:(NSUInteger)page
//{
//    if ( URL == nil )
//    return nil;
//
//    CGRect mediaRect = [ PDFView mediaRectForURL:URL atPage:page];
//
//    return [ UIImage imageWithPDFURL:URL atSize:mediaRect.size atPage:page preserveAspectRatio:YES ];
//}
//
//+(UIImage *) originalSizeImageWithPDFURL:(NSURL *)URL
//{
//    return [ UIImage originalSizeImageWithPDFURL:URL atPage:1 ];
//}

extension RSDImage {
    
    
    
}
