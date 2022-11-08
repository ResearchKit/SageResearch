//
//  RSDSchemaInfo.swift
//  Research
//

import Foundation

/// `RSDSchemaInfo` is a lightweight interface for schema information used to upload the results of a task.
/// The schema info is intended to allow for reproducing a previously presented survey where the survey may
/// have changed and requires revisioning to know what version of the survey task was run.
public protocol RSDSchemaInfo {
    
    /// A short string that uniquely identifies the associated result schema.
    var schemaIdentifier: String? { get }
    
    /// A revision number associated with the result schema.
    var schemaVersion: Int { get }
}
