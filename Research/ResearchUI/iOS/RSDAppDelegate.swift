//
//  RSDAppDelegate.swift
//  ResearchUI (iOS)
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

/// `RSDAppDelegate` is an optional class that can be used as the appDelegate for an application.
///
/// Using this class as the base class of your app delegate is not required, but is included as a
/// possible solution to certain common issues with setting up an app.
open class RSDAppDelegate : UIResponder, RSDAppOrientationLock, RSDAlertPresenter  {
    
    open var window: UIWindow?
    
    /// Override to set the shared factory on startup.
    open func instantiateFactory() -> RSDFactory {
        return RSDFactory()
    }
    
    /// Override and return a non-nil value to set up using a custom color palette with your app.
    open func instantiateColorPalette() -> RSDColorPalette? {
        return nil
    }
    
    /// Override and return a non-nil value to set up using custom color rules.
    open func instantiateColorRules() -> RSDColorRules? {
        guard let palette = instantiateColorPalette() else { return nil }
        return RSDColorRules(palette: palette)
    }
    
    /// Override and return a non-nil value to set up using custom font rules.
    open func instantiateFontRules() -> RSDFontRules? {
        return nil
    }
    
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization before application launch.
        
        // Set up color palette and factory.
        RSDFactory.shared = instantiateFactory()
        resourceLoader = ResourceLoader()
        let colorRules = instantiateColorRules()
        let fontRules = instantiateFontRules()
        if fontRules != nil || colorRules != nil {
            let version = colorRules?.version ?? fontRules?.version ?? RSDDesignSystem.currentVersion
            let cRules = colorRules ?? RSDColorRules(palette: .wireframe)
            let fRules = fontRules ?? RSDFontRules(version: version)
            let designSystem = RSDDesignSystem(version: version, colorRules: cRules, fontRules: fRules)
            designSystem.imageRules.insert(bundle: Bundle.init(for: RSDAppDelegate.self), at: .max)
            RSDDesignSystem.shared = designSystem
        }
        
        // Set the tint color.
        self.window?.tintColor = RSDDesignSystem.shared.colorRules.palette.primary.normal.color
                    
        return true
    }
    
    
    // ------------------------------------------------
    // MARK: RSDAlertPresenter
    // ------------------------------------------------
    
    /// Convenience method for presenting a modal view controller.
    open func presentModal(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let rootVC = self.window?.rootViewController else { return }
        var topViewController: UIViewController = rootVC
        while let presentedVC = topViewController.presentedViewController {
            if presentedVC.modalPresentationStyle != .fullScreen {
                presentedVC.dismiss(animated: false, completion: nil)
                break
            }
            else {
                topViewController = presentedVC
            }
        }
        topViewController.present(viewController, animated: animated, completion: completion)
    }
    
    
    // ------------------------------------------------
    // MARK: Lock orientation to portrait by default
    // ------------------------------------------------
    
    /// The default orientation lock if not overridden by setting the `orientationLock` property.
    ///
    /// An application that requires the *default* to be either portrait or landscape, while still
    /// setting the app allowed orientations to allow some view controllers to rotate must override
    /// this property to return those orientations only.
    ///
    open var defaultOrientationLock: UIInterfaceOrientationMask {
        return .all
    }
    
    /// The `orientationLock` property is used to override the default allowed orientations.
    ///
    /// - seealso: `defaultOrientationLock`
    open var orientationLock: UIInterfaceOrientationMask?
    
    /// - returns: The `orientationLock` or the `defaultOrientationLock` if nil.
    open func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock ?? defaultOrientationLock
    }
}

/// As of this writing, there is no simple way for an application to allow selectively locking
/// the orientation of the app to portrait, while still allowing *some* view controllers to
/// require landscape. This is intended as a work around for that limitation. Using this feature
/// requires the view controller that needs to change the orientation to set the
/// `orientationLock` in `viewWillAppear` and then clear the lock on `viewDidAppear`.
/// syoung 08/15/2019
///
/// - seealso: `RSDAppDelegate` for an example implementation.
public protocol RSDAppOrientationLock : UIApplicationDelegate {
    
    /// The default orientation lock if not overridden by setting the `orientationLock` property.
    var defaultOrientationLock: UIInterfaceOrientationMask { get }
    
    /// The `orientationLock` property is used to override the default allowed orientations.
    ///
    /// - seealso: `defaultOrientationLock`
    var orientationLock: UIInterfaceOrientationMask? { get set }
}

extension RSDAppOrientationLock {
    
    /// Convenience accessor for the appLock for applications where the app delegate implements
    /// this protocol.
    public static var appLock: RSDAppOrientationLock? {
        return UIApplication.shared.delegate as? RSDAppOrientationLock
    }
}
