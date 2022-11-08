//
//  RSDTaskGroup.swift
//  Research
//

import Foundation

/// `RSDTaskGroup` defines a subgrouping of tasks.  This is used in UI presentations where
/// the researchers wish to tie a group of activities and surveys together but allow the
/// user to perform them non-sequentially or with a break between the activities.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDTaskGroup {
    
    /// A short string that uniquely identifies the task group.
    var identifier: String { get }
    
    /// The primary text to display for the task group in a localized string.
    var title: String? { get }
    
    /// Additional detail text to display for the task group in a localized string.
    var detail: String? { get }
    
    /// An icon image that can be used for displaying the choice.
    var imageData: RSDImageData? { get }
    
    /// A list of the task references included in this group.
    var tasks: [RSDTaskInfo] { get }
}
