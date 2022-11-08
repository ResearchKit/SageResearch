//
//  SwiftUITestAppApp.swift
//
//

import SwiftUI
import ResearchUI

class AppDelegate: RSDSwiftUIAppDelegate {
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
