//
//  RSDDataStorageManager.swift
//  Research
//

import Foundation


/// The data storage manager controls storing of user data that is stored across task runs. It is a
/// composite protocol of the methods defined using Swift, which are required but can include Swift objects
/// and methods that conform to Objective-C protocols which allows for optional implementation of the
/// included methods.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDDataStorageManager : RSDSwiftDataStorageManager, RSDObjCDataStorageManager {
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDSwiftDataStorageManager : NSObjectProtocol {
    
    /// Returns data associated with the previous task run for a given task identifier.
    func previousTaskData(for taskIdentifier: RSDIdentifier) -> RSDTaskData?
    
    /// Store the given task run data.
    /// - parameters:
    ///     - data: The task data object to store.
    ///     - taskResult: The task result (if any) used to create the task data.
    func saveTaskData(_ data: RSDTaskData, from taskResult: RSDTaskResult?)
}

@available(*,deprecated, message: "Will be deleted in a future version.")
@objc public protocol RSDObjCDataStorageManager : NSObjectProtocol {
    
    /// Optional. Should survey questions be shown in subsequent runs using the results from a
    /// previous run?
    @objc optional func shouldUsePreviousAnswers(for taskIdentifier: String) -> Bool
}
