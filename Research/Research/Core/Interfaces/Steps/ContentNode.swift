//
//  ContentNode.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/**
 * This protocol is included here to support migration to Kotlin.
 *
 * - seealso: https://github.com/Sage-Bionetworks/AssessmentModel-KotlinNative
 */
public protocol ContentNode {
    
    /**
     * All content nodes have an identifier.
     */
    var identifier: String { get }

    /**
     * The primary text to display for the node in a localized string. The UI should display this using a larger font.
     */
    var title: String? { get }

    /**
     * A subtitle to display for the node in a localized string.
     */
    var subtitle: String? { get }

    /**
     * Detail text to display for the node in a localized string.
     */
    var detail: String? { get }

    /**
     *
     * Additional text to display for the node in a localized string at the bottom of the view.
     *
     * The footnote is intended to be displayed in a smaller font at the bottom of the screen. It is intended to be
     * used in order to include disclaimer, copyright, etc. that is important to display to the participant but should
     * not distract from the main purpose of the [Step] or [Assessment].
     */
    var footnote: String? { get }
}

public protocol ResultNode : ContentNode {
    func instantiateResult() -> ResultData
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol FormStep : ResultNode, RSDUIStep {
    
    /// A list of the child result nodes. Typically, these will be a collection of `Question`
    /// objects but that is not required.
    var children: [ResultNode] { get }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public extension FormStep {
    
    /// A form step instantiates a step result.
    func instantiateResult() -> ResultData {
        instantiateStepResult()
    }
    
    /// Check to see if the step result is a collection result and return that if valid.
    func instantiateCollectionResult() -> CollectionResult {
        guard let result = instantiateStepResult() as? CollectionResult else {
            debugPrint("WARNING!!! The instantiated step result does not conform to `CollectionResult`.")
            return CollectionResultObject(identifier: self.identifier)
        }
        return result
    }
}
