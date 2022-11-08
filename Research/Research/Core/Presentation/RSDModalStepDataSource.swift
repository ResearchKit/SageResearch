//
//  RSDModalStepDataSource.swift
//  Research
//

import Foundation


/// `RSDModalStepDataSource` extends `RSDTableDataSource` for a data source that includes entering
/// information using a modal step.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDModalStepDataSource : RSDTableDataSource {
    
    /// The taskViewModel to use to instantiate an appropriate view controller for the given modal step
    /// table item.
    ///
    /// - parameter tableItem: The table item that was selected.
    /// - returns: The step to display.
    func taskViewModel(for tableItem: RSDModalStepTableItem) -> RSDTaskViewModel?
    
    /// Save an answer from a subtask that was presented modally.
    /// - parameters:
    ///     - tableItem: The table item that was selected.
    ///     - taskViewModel: The task view model from which to save the answers.
    func saveAnswer(for tableItem: RSDModalStepTableItem, from taskViewModel: RSDTaskViewModel)
}
