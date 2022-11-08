//
//  RSDTableStep.swift
//  Research
//

import Foundation


/// `RSDTableStep` is a UI step that can be displayed using a `UITableView`.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDTableStep : RSDUIStep {
    
    /// Instantiate an instance of the data source with the data source mapping to the included list of
    /// supported ui hints.
    /// - parameters:
    ///     - parent: The taskViewModel for this table view controller.
    ///     - supportedHints: The ui hints that are supported by the calling table view controller.
    /// - returns: A table data source that maps to the supported hints, or `nil` if it is not compatible.
    func instantiateDataSource(with parent: RSDPathComponent?, for supportedHints: Set<RSDFormUIHint>) -> RSDTableDataSource?
}
