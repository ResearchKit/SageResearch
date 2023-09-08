//
//  SwiftUITestAppApp.swift
//
//

import SwiftUI
import ResearchUI

class AppDelegate: RSDAppDelegate {
}

@main
struct SwiftUITestAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
