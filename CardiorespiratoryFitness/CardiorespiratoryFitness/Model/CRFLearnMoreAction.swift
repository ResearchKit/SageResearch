//
//  CRFLearnMoreAction.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// This action vends a view controller that explains what a "normal" heart rate is.
struct CRFNormalHeartRateAction : RSDUIAction, RSDShowViewUIAction {

    /// Button title for this learn more button.
    let buttonTitle: String? = Localization.localizedString("HEARTRATE_LEARN_NORMAL_BUTTON")

    /// Instantiates a view controller defined by the storyboard.
    func instantiateViewController(for stepViewModel: RSDStepViewPathComponent) -> UIViewController {
        let bundle = Bundle(for: CRFLearnMoreViewController.self)
        let storyboard = UIStoryboard(name: "ActiveTaskSteps", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "NormalHeartRateLearnMore") as! CRFLearnMoreViewController
        vc.stepViewModel = stepViewModel
        return vc
    }
    
    // not used
    public var buttonIcon: RSDImage? {
        return nil
    }
}

/// This action vends a view controller that explains what a "normal" heart rate is.
struct CRFMeasuringTipsAction : RSDUIAction, RSDShowViewUIAction {
    
    /// Button title for this learn more button.
    let buttonTitle: String? = Localization.localizedString("HEARTRATE_LEARN_TIPS_BUTTON")
    
    /// Instantiates a view controller defined by the storyboard.
    func instantiateViewController(for stepViewModel: RSDStepViewPathComponent) -> UIViewController {
        let bundle = Bundle(for: CRFLearnMoreViewController.self)
        let storyboard = UIStoryboard(name: "ActiveTaskSteps", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "TipsForMeasuring") as! CRFLearnMoreViewController
        vc.stepViewModel = stepViewModel
        return vc
    }
    
    // not used
    public var buttonIcon: RSDImage? {
        return nil
    }
}
