//
//  RSDFileResultUtility.swift
//  Research
//

import Foundation

public protocol RSDFileManager : NSObjectProtocol {
    func fileExists(atPath path: String) -> Bool
    func isDeletableFile(atPath path: String) -> Bool
    func removeItem(at URL: URL) throws
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
}

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
extension FileManager : RSDFileManager {
}
#endif

/// `RSDFileResultUtility` is a utility for naming temporary files used to save task results.
public class RSDFileResultUtility {
    
    /// This utility will create a filename scrubbing the identifier string of any characters that
    /// are not alpha-numeric, dash, or underscore characters. Additionally, this utility will
    /// replace '.' and whitespace characters with an underscore. Finally, the string will be
    /// shortened (if needed) to 24 characters. If the resulting string is empty then a UUID will
    /// be created and this will be used as the name of the file.
    ///
    /// - parameter identifier: The string to use to create the file name.
    /// - returns: The scrubbed string.
    public static func filename(for identifier: String) -> String {
        // Scrub non-alphanumeric characters from the identifer
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert("-")
        characterSet.insert("_")
        characterSet.invert()
        var scrubbedIdentifier = identifier.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: " ", with: "_")
        while let range = scrubbedIdentifier.rangeOfCharacter(from: characterSet) {
            scrubbedIdentifier.removeSubrange(range)
        }
        scrubbedIdentifier = String(scrubbedIdentifier.prefix(24))
        return scrubbedIdentifier.count > 0 ? scrubbedIdentifier : String(UUID().uuidString)
    }
    
    /// Convenience method for creating a file URL to use as the location to save data.
    ///
    /// This utility will first create the output directory if needed. Then it will append the scrubbed
    /// filename using the `filename()` utility function. Finally, the url will be checked and if the
    /// file already exists, then the filename will be appended with a random 4-letter UUID code.
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
    public static func createFileURL(identifier: String, ext: String, outputDirectory: URL, shouldDeletePrevious: Bool = false) throws -> URL {
        
        let fileManager = RSDStudyConfiguration.shared.fileManager!
        
        // create the directory if needed
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        
        // Check the file name.
        var filename = self.filename(for: identifier)
        if let _ = RSDReservedFilename(rawValue: filename) {
            assertionFailure("\(filename) is a reserved file name.")
            let uuidCode = UUID().uuidString.prefix(4)
            filename.append("-\(uuidCode)")
        }
        
        // Check the url.
        let relativePath = (filename as NSString).appendingPathExtension(ext)!
        let url = URL(fileURLWithPath: relativePath, relativeTo: outputDirectory)
        if !fileManager.fileExists(atPath: url.path) {
            return url
        }
        else if shouldDeletePrevious, fileManager.isDeletableFile(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
                return url
            }
            catch let err {
                debugPrint("Failed to delete file. \(err)")
            }
        }
        
        let uuidCode = UUID().uuidString.prefix(4)
        return URL(fileURLWithPath: "\(filename)-\(uuidCode).\(ext)", relativeTo: outputDirectory)
    }
    
    /// Convenience method for creating a file URL for a given reserved file name to use as the location
    /// to save data.
    ///
    /// - parameter filename: The name of the file.
    /// - returns: String path for the given file name.
    @available(*, deprecated, message: "Support for BridgeSDK archive and export is deprecated. Please use BridgeClient and implement `FileArchivable` directly instead of `RSDArchivable`.")
    internal static func fileManifest(for filename: RSDReservedFilename) -> RSDFileManifest {
        let filename = (filename.stringValue as NSString).appendingPathExtension("json")!
        return RSDFileManifest(filename: filename, timestamp: Date(), contentType: "application/json")
    }
}

