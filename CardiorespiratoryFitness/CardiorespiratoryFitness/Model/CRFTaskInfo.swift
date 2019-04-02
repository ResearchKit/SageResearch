//
//  CRFTaskInfo.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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

/// A list of all the tasks included in this module.
public enum CRFTaskIdentifier : String, Codable, CaseIterable {
    
    /// Training task for measuring your heart rate.
    case training = "Heartrate Training"
    
    /// Measure your heart rate while resting.
    case resting = "Resting Heartrate"
    
    // TODO: syoung 04/02/2019 Remove commented out code. Leaving for now in case researchers change their mind again.
    // case restingMorning = "Morning Heartrate"
    
    /// Stair step VO2 max test.
    case stairStep = "Cardio Stair Step"
    
    func task(with factory: CRFFactory) -> RSDTaskObject {
        do {
            let transformer = CRFTaskTransformer(self)
            let mTask = try factory.decodeTask(with: transformer)
            let task = mTask as! RSDTaskObject
            
            // TODO: syoung 04/02/2019 Remove commented out code. Leaving for now in case researchers change their mind again.
            //            if self == .restingMorning, let intro = task.findStep(with: "introduction") as? RSDUIStepObject {
            //                intro.title = Localization.localizedString("HEARTRATE_MORNING_TITLE")
            //                if let navigator = task.stepNavigator as? RSDCopyStepNavigator {
            //                    let copy = navigator.copyAndRemove(["hr1", "feedback1"])
            //                    task = CRFTaskObject(identifier: self.stringValue,
            //                                         stepNavigator: copy,
            //                                         schemaInfo: task.schemaInfo,
            //                                         asyncActions: task.asyncActions,
            //                                         usesTrackedData: task.usesTrackedData)
            //                }
            //            }
            return task
        }
        catch let err {
            fatalError("Failed to decode the task. \(err)")
        }
    }
}

/// A task info object for the tasks included in this submodule.
public struct CRFTaskInfo : RSDTaskInfo, RSDEmbeddedIconVendor {

    /// The task identifier for this task.
    public let taskIdentifier: CRFTaskIdentifier
    
    /// The task build for this info.
    public let task: CRFTaskObject
    
    private init(taskIdentifier: CRFTaskIdentifier, task: CRFTaskObject) {
        self.taskIdentifier = taskIdentifier
        self.task = task
    }
    
    /// Default initializer.
    public init(_ taskIdentifier: CRFTaskIdentifier) {
        self.taskIdentifier = taskIdentifier
        
        // Pull the title, subtitle, and detail from the first step in the task resource.
        let factory = (RSDFactory.shared as? CRFFactory) ?? CRFFactory()
        self.task = taskIdentifier.task(with: factory) as! CRFTaskObject
        if let step = (task.stepNavigator as? RSDConditionalStepNavigator)?.steps.first as? RSDUIStep {
            self.title = step.title
            self.subtitle = step.text
            self.detail = step.detail
        }
        self.schemaInfo = self.task.schemaInfo
        
        // Set the default image icon.
        switch taskIdentifier {
        case .training, .resting:
            self.icon = try! RSDImageWrapper(imageName: "heartRateIcon", bundle: Bundle(for: CRFFactory.self))
        case .stairStep:
            self.icon = try! RSDImageWrapper(imageName: "stairStepIcon", bundle: Bundle(for: CRFFactory.self))
        }
    }
    
    /// The identifier is the task identifier for this task.
    public var identifier: String {
        return self.task.identifier
    }
    
    /// The title for the task.
    public var title: String?
    
    /// The subtitle for the task.
    public var subtitle: String?
    
    /// The detail for the task.
    public var detail: String?
    
    /// The image icon for the task.
    public var icon: RSDImageWrapper?
    
    /// Estimated minutes to perform the task.
    public var estimatedMinutes: Int {
        switch taskIdentifier {
        case .training:
            return 2
        case .resting:
            return 1
        case .stairStep:
            return 5
        }
    }
    
    /// A schema associated with this task info.
    public var schemaInfo: RSDSchemaInfo?
    
    /// Returns `task`.
    public var resourceTransformer: RSDTaskTransformer? {
        return self.task
    }
    
    public func copy(with identifier: String) -> CRFTaskInfo {
        let task = self.task.copy(with: identifier)
        var copy = CRFTaskInfo(taskIdentifier: taskIdentifier, task: task)
        copy.title = self.title
        copy.subtitle = self.subtitle
        copy.detail = self.detail
        copy.icon = self.icon
        copy.schemaInfo = self.schemaInfo
        return copy
    }
}

/// A task transformer for the resources included in this module.
public struct CRFTaskTransformer : RSDResourceTransformer, Decodable {

    private enum CodingKeys : String, CodingKey {
        case resourceName
    }
    
    public init(_ taskIdentifier: CRFTaskIdentifier) {
        switch taskIdentifier {
        case .training:
            self.resourceName = "Heartrate_Training"
        case .resting:
            self.resourceName = "Heartrate_Resting"
        case .stairStep:
            self.resourceName = "Cardio_Stair_Step"
        }
    }
    
    /// Name of the resource for this transformer.
    public let resourceName: String
    
    /// Get the task resource from this bundle.
    public var bundleIdentifier: String? {
        return factoryBundle?.bundleIdentifier
    }
    
    /// The factory bundle points to this framework. (nil-resettable)
    public var factoryBundle: Bundle? {
        get { return _bundle ?? Bundle(for: CRFFactory.self)}
        set { _bundle = newValue  }
    }
    private var _bundle: Bundle? = nil
    
    // MARK: Not used.
    
    public var classType: String? {
        return nil
    }
}

/// `RSDTaskGroupObject` is a concrete implementation of the `RSDTaskGroup` protocol.
public struct CRFTaskGroup : RSDTaskGroup, RSDEmbeddedIconVendor, Decodable {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case identifier, title, detail, icon
    }
    
    /// A short string that uniquely identifies the task group.
    public let identifier: String
    
    /// The primary text to display for the task group in a localized string.
    public let title: String?
    
    /// Additional detail text to display for the task group in a localized string.
    public let detail: String?
    
    /// The optional `RSDImageWrapper` with the pointer to the image.
    public let icon: RSDImageWrapper?
    
    /// The task group object is
    public let tasks: [RSDTaskInfo] = CRFTaskIdentifier.allCases.map { CRFTaskInfo($0) }
}

public protocol CRFTask : RSDTask {
    
    /// The camera settings to use for the heart rate steps (nil resettable).
    var cameraSettings : CRFCameraSettings? { get set }
}

extension RSDTaskObject : CRFTask {
    
    /// The camera settings to use for the heart rate steps (nil resettable).
    public var cameraSettings : CRFCameraSettings? {
        get { return heartRateSteps().first?.cameraSettings ?? nil }
        set {
            for step in heartRateSteps() {
                step.cameraSettings = newValue ?? CRFCameraSettings()
            }
        }
    }

    private func heartRateSteps() -> [CRFHeartRateStep] {
        guard let navigator = self.stepNavigator as? RSDConditionalStepNavigator else { return [] }
        let steps = navigator.steps.compactMap { (step) -> CRFHeartRateStep? in
            if let hrStep = step as? CRFHeartRateStep {
                return hrStep
            }
            guard let sectionStep = step as? RSDSectionStep else { return nil }
            return sectionStep.steps.first(where: { $0 is CRFHeartRateStep }) as? CRFHeartRateStep
        }
        return steps
    }
}

extension RSDTask {
    
    fileprivate func findStep(with identifier: String) -> RSDStep? {
        guard let navigator = self.stepNavigator as? RSDConditionalStepNavigator else { return nil }
        for step in navigator.steps {
            if let task = step as? RSDTask, let substep = task.findStep(with: identifier) {
                return substep
            }
            else if step.identifier == identifier {
                return step
            }
        }
        return nil
    }
}

