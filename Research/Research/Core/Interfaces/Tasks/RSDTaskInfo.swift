//
//  RSDTaskInfo.swift
//  Research
//

import Foundation


/// `RSDTaskInfo` includes information to display about a task before the task is fetched.
/// This can be used to display a collection of tasks and only load the task when selected
/// by the participant.
public protocol RSDTaskInfo : RSDCopyWithIdentifier, ContentNode {
    
    /// A short string that uniquely identifies the task.
    var identifier: String { get }
    
    /// The primary text to display for the task in a localized string.
    var title: String? { get }
    
    /// The subtitle text to display for the task in a localized string.
    var subtitle: String? { get }
    
    /// Additional detail text to display for the task. Generally, this would be displayed
    /// while the task is being fetched.
    var detail: String? { get }
    
    /// The estimated number of minutes that the task will take. If `0`, then this is ignored.
    var estimatedMinutes: Int { get }
    
    /// An icon image that can be used for displaying the choice.
    var imageData: RSDImageData? { get }
    
    /// Optional schema info to pass with the task info for this task.
    var schemaInfo: RSDSchemaInfo? { get }
    
    /// The resource transformer on `RSDTaskInfo` can be used in cases where the transformer is
    /// loaded from a resource by the task info (when decoded). If the task info is used as the
    /// information container for a **step** that loads the task using a service to fetch the
    /// task, then this pointer can be `nil`.
    var resourceTransformer : RSDTaskTransformer? { get }
}

public extension RSDTaskInfo {
    var footnote: String? { nil }
}
