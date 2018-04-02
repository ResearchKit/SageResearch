//
//  MCTTaskInfo.swift
//  MotorControl
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
public enum MCTTaskIdentifier : String, Codable {
    
    /// The walk and balance test.
    case walkAndBalance = "Walk and Balance"
    
    /// The tremor test.
    //case tremor = "Tremor"
    
    /// The tapping test.
    //case tapping = "Tapping"
    
    /// The default resource transformer for this task.
    public func resourceTransformer() -> RSDResourceTransformer {
        return MCTTaskTransformer(self)
    }
    
    /// List of all the task identifiers.
    public static func all() -> [MCTTaskIdentifier] {
        return [.walkAndBalance]//, .tremor, .tapping]
    }
}

/// A task info object for the tasks included in this submodule.
public struct MCTTaskInfo : RSDTaskInfo, RSDEmbeddedIconVendor {

    /// The task identifier for this task.
    public let taskIdentifier: MCTTaskIdentifier
    
    /// The task built for this info.
    public let task: RSDTaskObject
    
    private init(taskIdentifier: MCTTaskIdentifier, task: RSDTaskObject) {
        self.taskIdentifier = taskIdentifier
        self.task = task
    }
    
    /// Default initializer.
    public init(_ taskIdentifier: MCTTaskIdentifier) {
        self.taskIdentifier = taskIdentifier
        
        // Pull the title, subtitle, and detail from the first step in the task resource.
        let factory = RSDFactory.shared
        let task = try! factory.decodeTask(with: taskIdentifier.resourceTransformer()) as! RSDTaskObject
        self.task = task
        
        if let step = (task.stepNavigator as? RSDConditionalStepNavigator)?.steps.first as? RSDUIStep {
            self.title = step.title
            self.subtitle = step.text
            self.detail = step.detail
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
        return 3
    }
    
    /// A schema associated with this task info.
    public var schemaInfo: RSDSchemaInfo?
    
    /// Returns `task`.
    public var resourceTransformer: RSDTaskTransformer? {
        return self.task
    }
    
    public func copy(with identifier: String) -> MCTTaskInfo {
        let task = self.task.copy(with: identifier)
        var copy = MCTTaskInfo(taskIdentifier: taskIdentifier, task: task)
        copy.title = self.title
        copy.subtitle = self.subtitle
        copy.detail = self.detail
        copy.icon = self.icon
        copy.schemaInfo = self.schemaInfo
        return copy
    }
}

/// A task transformer for the resources included in this module.
public struct MCTTaskTransformer : RSDResourceTransformer, Decodable {

    private enum CodingKeys : String, CodingKey {
        case resourceName
    }
    
    public init(_ taskIdentifier: MCTTaskIdentifier) {
        switch taskIdentifier {
        case .walkAndBalance:
            self.resourceName = "Walk_And_Balance"
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
        get { return _bundle ?? Bundle(for: MCTFactory.self)}
        set { _bundle = newValue  }
    }
    private var _bundle: Bundle? = nil
    
    // MARK: Not used.
    
    public var classType: String? {
        return nil
    }
}
