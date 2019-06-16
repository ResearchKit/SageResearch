//
//  RSDVideoViewController.swift
//  ResearchUI
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

import UIKit
import AVKit
import AVFoundation

/// `RSDVideoViewController` is a simple view controller for showing a video. The base-class implementation
/// supports loading a video from a URL, video string, or `RSDResourceTransformer`. It is assumed that
/// the property will be set for one of these values.
open class RSDVideoViewController: AVPlayerViewController {
    
    /// Convenience method for instantiating a RSDVideoViewController and presenting it on top of the presenter UIViewController
    open class func present(action: RSDVideoViewUIAction, presenter: UIViewController) {
        
        var url: URL? = nil
        if action.isOnlineResourceURL() {
            url = URL(string: action.resourceName)
        } else {
            do {
                url = try action.resourceURL().url
            } catch let err {
                debugPrint("Error decoding video resource \(err)")
            }
        }
        
        guard let urlUnwrapped = url else { return }
        
        let player = AVPlayer(url: urlUnwrapped)
        let playerController = AVPlayerViewController()
        playerController.player = player
        presenter.present(playerController, animated: true) {
            player.play()
        }
    }
}
