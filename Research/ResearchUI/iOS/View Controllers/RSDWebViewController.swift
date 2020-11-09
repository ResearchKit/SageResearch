//
//  RSDWebViewController.swift
//  ResearchUI
//
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
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
import WebKit
import Research

/// `RSDWebViewController` is a simple view controller for showing a webview. The base-class implementation
/// supports loading a web view from a URL, HTML string, or `RSDResourceTransformer`. It is assumed that
/// the property will be set for one of these values.
open class RSDWebViewController: UIViewController, WKNavigationDelegate {
    
    /// The webview attached to this view controller.
    @IBOutlet public var webView: WKWebView!
    
    /// The loading indicator.
    @IBOutlet public var activityIndicator: UIActivityIndicatorView!
    
    /// The URL to load into the webview on `viewWillAppear()`.
    open var url: URL?
    
    /// The HTML string to load into the webview on `viewWillAppear()`.
    open var html: String?
    
    /// The resource to load into the webview on `viewWillAppear()`.
    open var resourceTransformer: RSDResourceTransformer?
    
    /// The design system to use for this controller.
    open var designSystem: RSDDesignSystem?
    
    private var _closeButtonTitle: String?
    private var _headerTitle: String?
    private var _usesBackButton: Bool = false
    private var _webviewLoaded = false
    
    /// Convenience method for instantiating a web view controller that is the root view controller for a
    /// navigation controller.
    open class func instantiateController(using designSystem: RSDDesignSystem = RSDDesignSystem(), action: RSDWebViewUIAction? = nil) -> (RSDWebViewController, UINavigationController) {
        let webVC = self.init()
        let navVC = UINavigationController(rootViewController: webVC)
        navVC.modalPresentationStyle = .fullScreen
        navVC.isNavigationBarHidden = true

        // Set up the model.
        webVC.designSystem = designSystem
        webVC.resourceTransformer = action
        webVC._closeButtonTitle = action?.closeButtonTitle
        webVC._headerTitle = action?.title
        // TODO: syoung 03/28/2019 Implement custom animation to show "push on" style of view.
        webVC._usesBackButton = action?.usesBackButton ?? false

        return (webVC, navVC)
    }
    
    // MARK: View management
    
    /// Override `viewDidLoad()` to instantiate a webview if there wasn't one created using a storyboard or nib.
    open override func viewDidLoad() {
        super.viewDidLoad()
        if activityIndicator == nil {
            self.view.backgroundColor = UIColor.white
            activityIndicator = UIActivityIndicatorView(style: .gray)
            self.view.addSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.rsd_alignCenterVertical(padding: 0)
            activityIndicator.rsd_alignCenterHorizontal(padding: 0)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
        }
        if webView == nil {
            let configuration = webViewConfiguration()
            let subview = WKWebView(frame: self.view.bounds, configuration: configuration)
            subview.translatesAutoresizingMaskIntoConstraints = false
            self.view.insertSubview(subview, at: 0)
            subview.navigationDelegate = self
            subview.backgroundColor = UIColor.white
            self.view.backgroundColor = UIColor.white
            
            self.webView = subview
            
            if let closeTitle = self._closeButtonTitle {
                layoutForFooterCloseButton(closeTitle)
            }
            else if _headerTitle != nil || _usesBackButton {
                layoutForHeaderCloseButton()
            }
            else {
                // Older web views that should retain the original styling of the view.
                self.webView.rsd_alignAllToSuperview(padding: 0)
            }
        }
        loadWebview()
    }
    
    func layoutForFooterCloseButton(_ closeTitle: String) {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        
        // set up a footer with a close action.
        let footer = RSDGenericNavigationFooterView(frame: .zero)
        footer.isBackHidden = true
        footer.isSkipHidden = true
        footer.addNextButtonIfNeeded()
        let button = footer.nextButton!
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.setTitle(closeTitle, for: .normal)
        footer.setDesignSystem(designSystem, with: designSystem.colorRules.backgroundLight)
        
        // set up constraints.
        footer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(footer)
        footer.rsd_alignToSuperview([.leading, .trailing, .bottomMargin], padding: 0.0)
        self.webView.rsd_alignToSuperview([.leadingMargin, .trailingMargin, .topMargin], padding: 0.0)
        self.webView.rsd_alignAbove(view: footer, padding: 0)
    }
    
    func layoutForHeaderCloseButton() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        
        let header = RSDTableStepHeaderView(frame: .zero)
        header.titleLabel?.text = self._headerTitle
        header.shouldShowProgress = false
        header.isStepLabelHidden = true
        if _usesBackButton {
            let image = UIImage(named: "backArrowHeader", in: Bundle.module, compatibleWith: self.view.traitCollection)
            header.cancelButton?.setImage(image, for: .normal)
        }
        else {
            let image = UIImage(named: "closeActivity", in: Bundle.module, compatibleWith: self.view.traitCollection)
            header.cancelButton?.setImage(image, for: .normal)
        }
        header.cancelButton?.addTarget(self, action: #selector(close), for: .touchUpInside)
        let background = designSystem.colorRules.backgroundPrimary
        header.setDesignSystem(designSystem, with: background)
        
        // set up constraints.
        header.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(header)
        let statusBackground = RSDStatusBarBackgroundView(frame: .zero)
        statusBackground.backgroundColor = background.color
        statusBackground.overlayColor = background.usesLightStyle ? UIColor.clear : RSDColor.black.withAlphaComponent(0.1)
        self.view.addSubview(statusBackground)
        statusBackground.alignToStatusBar()
        header.rsd_alignBelow(view: statusBackground, padding: 0.0)
        header.rsd_alignToSuperview([.leading, .trailing], padding: 0.0)
        self.webView.rsd_alignToSuperview([.leadingMargin, .trailingMargin, .bottomMargin], padding: 0.0)
        self.webView.rsd_alignBelow(view: header, padding: 0)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let designSystem = self.designSystem,
            (self._usesBackButton || self._headerTitle != nil)
            else {
                return .default
        }
        let background = designSystem.colorRules.backgroundPrimary
        return background.usesLightStyle ? .lightContent : .default
    }
    
    /// Override `viewDidAppear()` to load the webview on first appearance.
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadWebview()
    }
    
    func loadWebview() {
        guard !_webviewLoaded &&
            (self.url != nil || self.html != nil || self.resourceTransformer != nil)
            else {
                return
        }
        _webviewLoaded = true

        if let url = self.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        else if let html = self.html {
            // Include main bundle resourceURL as the baseURL so any stylesheets and images from the
            // bundle that are referenced in the HTML will load in the UIWebView.
            webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
        }
        else if let resource = resourceTransformer {
            if resource.isOnlineResourceURL(), let url = URL(string: resource.resourceName) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            else {
                do {
                    let (data, _) = try resource.resourceData(ofType: .html)
                    if let html = String(data: data, encoding: String.Encoding.utf8) {
                        webView.loadHTMLString(html, baseURL: Bundle.main.resourceURL)
                    } else {
                        loadFailed()
                    }
                } catch let err {
                    loadFailed(with: err)
                }
            }
        }
    }
    
    /// Set up the desired configuration for the webview. Default implementation activates all data detector types.
    open func webViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = .all
        return configuration
    }
    
    /// Failed to load the webview. Default implementation will print the error to the console but is otherwise silent.
    open func loadFailed(with error: Error? = nil) {
        if let err = error {
            debugPrint("Failed to load resource. \(err)")
        } else {
            debugPrint("Failed to load.")
        }
    }
    
    /// Dismiss the view controller that was presented modally.
    @objc open func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: WKNavigationDelegate
    
    /// If the webview request is a clicked link then open using the `UIApplication.open()` method.
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
    
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
        self.loadFailed(with: error)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
