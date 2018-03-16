//
//  CRFStairStepViewController.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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
import ResearchSuiteUI
import ResearchSuite

public class CRFStairStepViewController: RSDActiveStepViewController {
    
    /// The pointer to the audio player.
    private var audioPlayer: AVAudioPlayer!
    
    /// The image view that is used to show the animation.
    private var animationView: UIImageView? {
        return (self.navigationHeader as? RSDStepHeaderView)?.imageView
    }
    
    /// Override `viewDidLoad()` to open the audio URL.
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let bundle = Bundle(for: CRFStairStepViewController.self)
            let url = bundle.url(forResource: "stairStepAudio", withExtension: "m4a")!
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error {
            debugPrint("Failed to open audio file. \(error)")
        }
    }
    
    /// Override `viewWillAppear()` to stop the stair step animation until the accelerometers are ready.
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView?.stopAnimating()
    }
    
    /// Override `performStartCommands()` to start the audio and animation after a delay.
    /// This allows the view controller transition to finish before starting the step.
    public override func performStartCommands() {
        // Use a delay to show the "Stand still" text for the instruction
        // to give the user a moment to prepare.
        let delay = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
            self?._finishStart()
        }
    }
    
    private func _finishStart() {
        guard self.isVisible else { return }
        audioPlayer.play()
        animationView?.startAnimating()
        super.performStartCommands()
    }
    
    /// Override `stop()` to stop the audio and animation.
    public override func stop() {
        super.stop()
        self.audioPlayer.stop()
        animationView?.stopAnimating()
    }
    
    /// Override the timer interval and set to 96 beats per minute.
    public override var timerInterval: TimeInterval {
        return _metronomeInterval
    }
    private let _metronomeInterval: TimeInterval = 60 / 96
}
