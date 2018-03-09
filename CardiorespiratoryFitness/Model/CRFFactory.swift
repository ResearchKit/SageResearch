//
//  CRFFactory.swift
//  CardiorespiratoryFitness
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

import UIKit

extension RSDStepType {
    static let heartRate: RSDStepType = "heartRate"
}

open class CRFFactory: RSDFactory {

    /// Override the base factory to vend the heart rate step.
    override open func decodeStep(from decoder: Decoder, with type: RSDStepType) throws -> RSDStep? {
        switch type {
        case .heartRate:
            return try CRFHeartRateStep(from: decoder)
        default:
            return try super.decodeStep(from: decoder, with: type)
        }
    }
    
    /// Override the base factory to vend a heart rate section transformer.
    override open func decodeSectionStepTransformer(from decoder: Decoder) throws -> RSDSectionStepTransformer {
        guard let transformerType = try self.typeName(from: decoder), transformerType == RSDStepType.heartRate.stringValue else {
            return try super.decodeSectionStepTransformer(from: decoder)
        }
        return RSDResourceTransformerObject(resourceName: "HeartrateStep", bundleIdentifier: Bundle(for: CRFFactory.self).bundleIdentifier, classType: nil)
    }
}


