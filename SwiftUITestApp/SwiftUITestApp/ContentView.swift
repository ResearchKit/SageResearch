//
//  ContentView.swift
//  SwiftUITestApp
//
//  Created by Shannon Young on 9/30/21.
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
