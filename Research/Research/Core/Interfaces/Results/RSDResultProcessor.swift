//
//  RSDResultProcessor.swift
//  Research (iOS)
//

import Foundation

/// This is a hook to allow custom post-processing of the results. Typically, it is recommended that
/// Assessment creators should processs results as a part of navigation, using a custom
/// `RSDStepViewModel`, or as a part of the archiving process. That said, there was a special request
/// to include this method call so here it is. This is called when a method is marked as completed
/// and before the call to handle completed results. syoung 11/25/2020
///
/// If you are beginning a new project using these frameworks, I *strongly* recommend against using
/// this feature. It is *not* used by Sage Bionetworks in our production applications. Consequently,
/// it is only tested using functional/unit tests and *not* tested by Sage Research in any of our
/// assessments. In other words, it is provided as-is and it is our recommendation that you unit
/// test this feature in your own code if you choose to use it. When unit testing, please keep in
/// mind that *your* assessments may be included by researchers as a part of a larger assessment,
/// that may include additional questions or instructions for the participant.
///
/// Instead, I recommend one of the previously developed paths for mutating the result set:
///
/// 1. Implement a custom result that adhers to the `RSDTaskRunResult` protocol and have your
///    `RSDTask` implementation override `instantiateTaskResult()`. If your implementation is a
///    class then you can use `didSet` to respond to changes to the result set and/or implement
///    custom serialization of the result.
/// 2. Have the `RSDStepNavigator` use the `step(after:with:)` method to append custom processed
///    results to the task result.
/// 3. Use a custom implementation of `RSDStepViewModel` to handle final "scoring" and add the
///    result as appropriate.
///
public protocol RSDResultProcessor {
    func processResults(taskViewModel: RSDTaskViewModel, taskResult: inout RSDTaskResult)
}
