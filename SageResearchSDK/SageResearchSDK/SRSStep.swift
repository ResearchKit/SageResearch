//
//  SRSStep.swift
//  SageResearchSDK
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/**
 `SRSStep` is the base protocol for the steps that can compose a task for presentation using a controller appropriate to the device and applicaytion. Each `SRSStep` object represents one logical piece of data entry, information, or activity in a larger task.
 
 There are two base implementations included in this SDK. `SRSTaskStep` is used to define a subgrouping of steps such as a section in a longer survey. `SRSUIStep` is used to define a display step. Depending upon the display device, more than one `SRSUIStep` might be shown on a given page. For example, a section of a survey may display multiple fields on an iPad whereas each question in the survey is shown on a new page for an iPhone.
 
 A step can be a question, an active test, or a simple instruction. An `SRSStep` subclass is usually paired with an `SRSStepController` that controls the actions of the step.
 */
public protocol SRSStep {
    
    /**
     A short string that uniquely identifies the step within the task. The identifier is reproduced in the results of a step history.
     
     In some cases, it can be useful to link the step identifier to a unique identifier in a database; in other cases, it can make sense to make the identifier human readable.
     */
    var identifier: String { get }
    
    /**
     Validate the step to check for any configuration that should throw an error.
     */
    func validate() throws
}

/**
 `SRSTaskStep` is used to define a logical subgrouping of steps such as a section in a longer survey or an active step that includes an instruction step, countdown step, and activity step.
 */
public protocol SRSTaskStep: SRSStep {
    
    /**
     The task used to define this subgrouping of steps.
     */
    var subtask: SRSTask { get }
}

extension SRSTaskStep {
    
    public var identifier: String {
        return subtask.identifier
    }
}

/**
 `SRSUIStep` is used to define a single "display unit". 
 */
public protocol SRSUIStep: SRSStep {
    
    /**
     The primary text to display for the step in a localized string.
     */
    var title: String? { get }
    
    /**
     Additional text to display for the step in a localized string.
     
     The additional text is displayed in a smaller font below `title`. If you need to display a long question, it can work well to keep the title short and put the additional content in the `text` property.
     */
    var text: String? { get }
    
    /**
     Additional detailed explanation for the step.
     
     The font size and display of this property will depend upon the device type.
     */
    var detail: String? { get }
    
    /**
     Additional text to display for the step in a localized string at the bottom of the view.
     
     The footnote is displayed in a smaller font at the bottom of the screen. It is intended to be used in order to include disclaimer, copyright, etc. that is important to display in the step but should not distract from the main purpose of the step.
     */
    var footnote: String? { get }

    /**
     An image to display before the `title`, `text`, and `detail`. This would be displayed above or to the left of the text, depending upon the orientation of the screen.
     
     @param rect    The size of the image view used to display the image.
     
     @return        The image to display.
     */
    func imageBefore(in rect: CGRect) -> UIImage?
    
    /**
     An image to display after the `title`, `text`, and `detail`. This would be displayed below or to the right of the text, depending upon the orientation of the screen.
     
     @param rect    The size of the image view used to display the image.
     
     @return        The image to display.
     */
    func imageAfter(in rect: CGRect) -> UIImage?
    
    /**
     Customizable actions to return for a given action type. The `SRSStepController` can use these to customize the display of buttons to the user. If nil, `shouldHideAction()` will be called to determine if the default action should be used or if the action button should be hidden.
     
     @param actionType  The action type for the button.
     
     @return            A custom UI action for this button. If nil, the default action will be used.
     */
    func action(for actionType: SRSUIActionType) -> SRSUIAction?
    
    /**
     Should the action button be hidden?
     
     @param actionType  The action type for the button.
     
     @return            Whether or not the button should be hidden.
     */
    func shouldHideAction(for actionType: SRSUIActionType) -> Bool
}

/**
 For the case where a `SRSUIStep` has action such as "start walking" or "stop walking", the step may also implement the `SBAActiveUIStep` protocol to allow for spoken instruction.
 */
public protocol SRSActiveUIStep: SRSUIStep {
    
    /**
     The duration of time to run the step. If `0`, then this value is ignored.
     */
    var duration: TimeInterval { get }
    
    /**
     Localized text that represents an instructional voice prompt. Instructional speech begins when the step passes the time indicated by the given time.  If `timeInterval` is greater than or equal to `duration` or is equal to `Double.infinity`, then the spoken instruction should be returned for when the step is finished.
     
     If VoiceOver is active, the instruction is spoken by VoiceOver.
     
     @param timeInterval    The time interval at which to speak the instruction.
     
     @return                The localized instruction to speak.
     */
    func spokenInstruction(at timeInterval: TimeInterval) -> String?
}

/**
 Additional properties used in creating a form input.
 */
public protocol SRSFormUIStep: SRSUIStep {
    
    /**
     The items array is used to hold a logical subgrouping of form items. If this array holds more than one form item, that form item should describe an input that is uses a logical subgrouping such as blood pressure, height (ft-in), or given/family name.
     */
    var formItems: [SRSFormItem] { get }
}


