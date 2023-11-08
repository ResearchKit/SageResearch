//
//  RSDAppDelegate.swift
//  ResearchUI (iOS)
//

import Foundation
import UIKit
import Research
import SharedMobileUI

/// Call directly in app launch if not inheriting from `RSDAppDelegate`.
public final class ResearchUI {
    public static func setup(defaultFactory: RSDFactory = .init()) {
        RSDFactory.shared = defaultFactory
        resourceLoader = ResourceLoader()
        LocalizationBundle.registerDefaultBundlesIfNeeded()
    }
}

/// `RSDAppDelegate` is an optional class that can be used as the appDelegate for an application.
///
/// Using this class as the base class of your app delegate is not required, but is included as a
/// possible solution to certain common issues with setting up an app.
@available(iOS 13.0, *)
open class RSDAppDelegate : UIResponder, UIApplicationDelegate, RSDAlertPresenter  {
    
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
        ResearchUI.setup(defaultFactory: instantiateFactory())
        let colorRules = instantiateColorRules()
        let fontRules = instantiateFontRules()
        if fontRules != nil || colorRules != nil {
            let version = colorRules?.version ?? fontRules?.version ?? RSDDesignSystem.currentVersion
            let cRules = colorRules ?? RSDColorRules(palette: .wireframe)
            let fRules = fontRules ?? RSDFontRules(version: version)
            let designSystem = RSDDesignSystem(version: version, colorRules: cRules, fontRules: fRules)
            designSystem.imageRules.insert(bundle: Bundle.module, at: .max)
            RSDDesignSystem.shared = designSystem
        }
        
        // Set the tint color.
        self.window?.tintColor = RSDDesignSystem.shared.colorRules.palette.primary.normal.color
        
        // Set the default orientation lock equal to the lock defined by this app.
        AppOrientationLockUtility.defaultOrientationLock = self.defaultOrientationLock
                    
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
        return .portrait
    }
    
}

