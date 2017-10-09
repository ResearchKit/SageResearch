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
public protocol RSDResult : NSCopying {
    
    /**
     The identifier associated with the task, step, or asyncronous action.
     */
    var identifier: String { get }
    
    /**
     The start date timestamp for the result.
     */
    var startDate: Date { get }
    
    /**
     The end date timestamp for the result.
     */
    var endDate: Date { get }
}


/**
 A result associated with a task. This object includes a step history, task run UUID, schema identifier, and asyncronous results.
 */
public protocol RSDTaskResult : RSDResult, RSDSchemaInfo {
    
    /**
     A unique identifier for this task run.
     */
    var taskRunUUID: UUID { get }
    
    /**
     A listing of the step history for this task. The listed step results should *only* include the last result for any given step.
     */
    var stepHistory: [RSDResult] { get }
    
    /**
     A list of all the asyncronous results for this task. The list should include uniquely identified results.
     */
    var asyncResults: [RSDResult]? { get }
}


/**
 A collection of results associated with a given step. This can be used where the step has multiple results.
 */
public protocol RSDStepCollectionResult : RSDResult {
    
    /**
     A list of multiple results associated with this step.
     */
    var stepResults: [RSDResult] { get }
}


/**
 A result that can be described using a single value.
 */
public protocol RSDAnswerResult : RSDResult {
    
    /**
     The answer for the result.
     */
    var value: Any? { get }
    
    /**
     The data type of the answer result.
     */
    var dataType: RSDFormDataType { get }
    
    /**
     Any additional information associated with this result such as unit.
     */
    var metadata: [String : Any]? { get }
}
