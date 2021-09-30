//
//  ContentView.swift
//  SwiftUITestApp
//
//
//  Copyright © 2021 Sage Bionetworks. All rights reserved.
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

import SwiftUI
import Research
import ResearchUI

struct ContentView: View {
    @State var presentedTask: Orientation? 
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Hello, world!")
                .padding()
            Button("Show Portrait", action: {
                self.presentedTask = .portrait
            })
            Button("Show Landscape", action: {
                self.presentedTask = .landscape
            })
        }
        .fullScreenCover(item: $presentedTask) { current in
            TaskViewRepresentable(current, $presentedTask)
        }
    }
}

final class TaskViewRepresentable : NSObject, UIViewControllerRepresentable, RSDTaskViewControllerDelegate {
    let current: Orientation
    @Binding var orientation: Orientation?
    
    init(_ current: Orientation, _ orientation: Binding<Orientation?>) {
        self.current = current
        self._orientation = orientation
    }
    
    func makeUIViewController(context: Context) -> RSDTaskViewController {
        let vc = RSDTaskViewController(task: CustomTask(current))
        vc.delegate = self
        return vc
    }
    
    func updateUIViewController(_ uiViewController: RSDTaskViewController, context: Context) {
        // do nothing
    }
    
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?) {
        self.orientation = nil
    }
    
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel) {
        // do nothing
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
