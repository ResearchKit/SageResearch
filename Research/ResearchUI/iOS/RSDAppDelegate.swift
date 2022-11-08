//
//  RSDAppDelegate.swift
//  ResearchUI (iOS)
//

import Foundation
import UIKit
import Research

/// `RSDAppDelegate` is an optional class that can be used as the appDelegate for an application.
///
/// Using this class as the base class of your app delegate is not required, but is included as a
/// possible solution to certain common issues with setting up an app.
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
        RSDFactory.shared = instantiateFactory()
        resourceLoader = ResourceLoader()
        LocalizationBundle.registerDefaultBundlesIfNeeded()
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
    
    @available(*, deprecated, message: "Use `AppOrientationLockUtility.setOrientationLock()` instead.")
    open var orientationLock: UIInterfaceOrientationMask? {
        get { AppOrientationLockUtility.orientationLock }
        set { AppOrientationLockUtility.setOrientationLock(newValue) }
    }
}

/// A SwiftUI app doesn't honor the `supportedInterfaceOrientations` property on a UIViewController so this work-around
/// allows those apps to use the app lock in conjunction with the app-level `supportedInterfaceOrientations` instead.
open class RSDSwiftUIAppDelegate : RSDAppDelegate {
    
    open override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        AppOrientationLockUtility.shouldAutorotate = true
        return super.application(application, willFinishLaunchingWithOptions: launchOptions)
    }
    
    /// - returns: The `orientationLock` or the `defaultOrientationLock` if nil.
    open func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppOrientationLockUtility.currentOrientationLock
    }
}

/// With SwiftUI, the `UIApplication.shared.delegate` returns nil but the delegate can still be set
/// and still requires using the method
/// `application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?)`
/// to set up orientation properly. Overriding `supportedInterfaceOrientations` in the UIViewController is not enough.
///
/// syoung 09/28/2021
public class AppOrientationLockUtility {
    
    /// The current supported interface orientations.
    static public var currentOrientationLock: UIInterfaceOrientationMask {
        orientationLock ?? defaultOrientationLock
    }
    
    /// By default, should the device rotate using forced device rotation when setting the orientation lock?
    /// For apps that use a Storyboard and view controllers, this shouldn't be necessary b/c the view controllers will
    /// honor the `UIViewController.supportedInterfaceOrientations` property and the
    /// `UIViewController.shouldAutorotate`.
    ///
    /// As of this writing (syoung 09/30/2021) SwiftUI does not honor that property even when showing a
    /// view controller. Or more specfically, some OS versions and devices do and some do not. Therefore,
    /// if using SwiftUI as the main entry to the app, this must be set == `true` to force rotation changes.
    ///
    public static var shouldAutorotate: Bool = false
    
    /// The default orientation lock if not overridden by setting the `orientationLock` property.
    ///
    /// An application that requires the *default* to be either portrait or landscape, while still
    /// setting the app allowed orientations to allow some view controllers to rotate, must set
    /// this property to return those orientations only.
    ///
    static public var defaultOrientationLock: UIInterfaceOrientationMask = .portrait
    
    /// The `orientationLock` property is used to override the default allowed orientations.
    ///
    /// - seealso: `defaultOrientationLock`
    static public private(set) var orientationLock: UIInterfaceOrientationMask?
    
    static public func reset() {
        setOrientationLock(nil)
    }
    
    /// Set the orientation lock.
    static public func setOrientationLock(_ newValue: UIInterfaceOrientationMask?, rotateIfNeeded: Bool = shouldAutorotate) {
        orientationLock = newValue
        guard rotateIfNeeded else { return }
        
        // Get initial orientation
        let windowOrientation: UIInterfaceOrientation? = {
            if #available(iOS 13.0, *) {
                return UIApplication.shared.keyWindow?.windowScene?.interfaceOrientation
            }
            else {
                return UIApplication.shared.statusBarOrientation
            }
        }()
        let device = UIDevice.current
        let currentOrientation: UIDeviceOrientation = windowOrientation.flatMap { .init(rawValue: $0.rawValue) } ?? device.orientation
        var orientation = currentOrientation

        // Compare current to desired.
        switch currentOrientationLock {
        case .portrait:
            orientation = .portrait
        case .landscapeLeft:
            orientation = .landscapeLeft
        case .landscapeRight:
            orientation = .landscapeRight
        case .portraitUpsideDown:
            orientation = .portraitUpsideDown
        case .landscape:
            if orientation != .landscapeRight && orientation != .landscapeLeft {
                orientation = .landscapeRight
            }
        default:
            break
        }
        
        // Set the device orientation and rotate.
        device.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

extension UIInterfaceOrientationMask {
    func names() -> [String] {
        let mapping: [String : UIInterfaceOrientationMask] = [
            "portrait" : .portrait,
            "landscape" : .landscape
        ]
        return mapping.compactMap { self.contains($0.value) ? $0.key : nil }
    }
}

extension UIDeviceOrientation {
    var name: String {
        switch self {
        case .portrait:
            return "portrait"
        case .landscapeRight:
            return "landscapeRight"
        case .landscapeLeft:
            return "landscapeLeft"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .faceUp:
            return "faceUp"
        case .faceDown:
            return "faceDown"

        default:
            return "unknown"
        }
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
@available(*, deprecated, message: "Use `AppOrientationLockUtility` instead.")
public protocol RSDAppOrientationLock : UIApplicationDelegate {
    
    /// The default orientation lock if not overridden by setting the `orientationLock` property.
    var defaultOrientationLock: UIInterfaceOrientationMask { get }
    
    /// The `orientationLock` property is used to override the default allowed orientations.
    ///
    /// - seealso: `defaultOrientationLock`
    var orientationLock: UIInterfaceOrientationMask? { get set }
}

@available(*, deprecated, message: "Use `AppOrientationLockUtility` instead.")
extension RSDAppOrientationLock {
    
    /// Convenience accessor for the appLock for applications where the app delegate implements
    /// this protocol.
    public static var appLock: RSDAppOrientationLock? {
        return UIApplication.shared.delegate as? RSDAppOrientationLock
    }
}

@available(*, deprecated, message: "Use `AppOrientationLockUtility` instead.")
extension RSDAppDelegate : RSDAppOrientationLock {
}
