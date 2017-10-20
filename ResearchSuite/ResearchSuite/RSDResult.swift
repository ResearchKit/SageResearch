//
//  RSDResult.swift
//  ResearchSuite
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
 A result associated with a task, step, or asyncronous action.
 */
public protocol RSDResult : Codable {
    
    /**
     The identifier associated with the task, step, or asyncronous action.
     */
    var identifier: String { get }
    
    /**
     A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
     */
    var type: String { get }
    
    /**
     The start date timestamp for the result.
     */
    var startDate: Date { get }
    
    /**
     The end date timestamp for the result.
     */
    var endDate: Date { get set }
}

/**
 A collection of results associated with a step that may have more that one result.
 */
public protocol RSDStepCollectionResult : RSDResult {
    
    /**
     The list of input results associated with this step. These are generally assumed to be answers to field inputs, but they are not required to implement the `RSDAnswerResult` protocol.
     */
    var inputResults: [RSDResult] { get set }
}

/**
 A result associated with a task. This object includes a step history, task run UUID, schema identifier, and asyncronous results.
 */
public protocol RSDTaskResult : RSDResult {
    
    /**
     A unique identifier for this task run.
     */
    var taskRunUUID: UUID { get }
    
    /**
     Schema info associated with this task.
     */
    var schemaInfo: RSDSchemaInfo? { get set }
    
    /**
     A listing of the step history for this task or section. The listed step results should *only* include the last result for any given step.
     */
    var stepHistory: [RSDResult] { get set }

    /**
     A list of all the asyncronous results for this task. The list should include uniquely identified results.
     */
    var asyncResults: [RSDResult]? { get set }
}


/**
 A result that can be described using a single value.
 */
public protocol RSDAnswerResult : RSDResult {
    
    /**
     The answer type of the answer result. This includes coding information required to encode and decode the value. The value is expected to conform to one of the coding types supported by the answer type.
     */
    var answerType: RSDAnswerResultType { get }
    
    /**
     The answer for the result.
     */
    var value: Any? { get set }
}
