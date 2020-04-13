//
//  ViewController.swift
//  JsonFileConverter
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

import Cocoa
import Research

class ViewController: NSViewController {
    
    @IBOutlet weak var dragView: DragView!
    @IBOutlet weak var scrollText: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        dragView.didDrag = didDropFile(url:)
    }

    func didDropFile(url: URL) {
        print("Decoding JSON from \(url)")
        do {
            let data = try Data(contentsOf: url)
            let factory = RSDFactory.shared
            let decoder = factory.createJSONDecoder()
            let task = try decoder.decode(RSDTaskObject.self, from: data)
            guard let steps = (task.stepNavigator as? RSDOrderedStepNavigator)?.steps
                else {
                    print("Navigator is not an ordered step navigator")
                    return
            }
            
            let conversionFactory = QuestionConvertionFactory()
            
            steps.forEach { step in
                guard let formStep = step as? ConvertableFormStep else { return }
                do {
                    let questionStep = try formStep.convertToQuestion(using: conversionFactory)
                    let data = try questionStep.rsd_jsonEncodedData()
                    if let string = String(data: data, encoding: .utf8) {
                        print("\n\n\(string)\n\n")
                    }
                    else {
                        print("Failed to decode string")
                    }
                } catch let err {
                    print("Failed to convert \(step.identifier): \(err)")
                }
            }
        }
        catch let err {
            print("Failed to open or decode file: \(err)")
        }
    }
}

