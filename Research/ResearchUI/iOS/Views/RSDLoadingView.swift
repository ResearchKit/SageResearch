//
//  RSDLoadingView.swift
//  ResearchUI (iOS)
//

import Foundation
import UIKit
import Research

/// `RSDLoadingViewControllerProtocol` is a convenience protocol to allow UIViewControllers that do
/// not inherit from the same subclass to show and hide a loading indicator.
public protocol RSDLoadingViewControllerProtocol {
    
    /// The container view for the loading indicator.
    var loadingContainerView: UIView! { get }
}

@available(iOS 13.0, *)
extension RSDLoadingViewControllerProtocol {
    
    /// Find the standard loading view that was added to this view controller.
    public var standardLoadingView: RSDLoadingView? {
        return self.loadingContainerView.subviews.first(where:{ $0 is RSDLoadingView }) as? RSDLoadingView
    }
    
    /// Show the standard loading view.
    public func showStandardLoadingView() {
        var loadingView: RSDLoadingView! = self.standardLoadingView
        if (loadingView == nil) {
            // if nil, create and add the loading view
            loadingView = RSDLoadingView(frame: self.loadingContainerView.bounds)
            loadingView.isHidden = true
            self.loadingContainerView.addSubview(loadingView)
            loadingView.rsd_alignAllToSuperview(padding: 0)
        }
        if (!loadingView.isAnimating || loadingView.isHidden) {
            loadingView.startAnimating()
        }
    }
    
    /// Hide the standard loading view.
    public func hideStandardLoadingView(_ completion: (() -> Void)? = nil) {
        guard let loadingView = standardLoadingView, loadingView.isAnimating else {
            completion?()
            return
        }
        loadingView.stopAnimating({
            loadingView.removeFromSuperview()
            completion?()
        })
    }
}

/// `RSDLoadingView` is a simple loading view for displaying a loading indicator in a view.
@available(iOS 13.0, *)
open class RSDLoadingView: UIView {
    
    /// Is the loading indicator animating?
    open var isAnimating: Bool {
        return loadingIndicator.isAnimating
    }
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = false
        loadingIndicator.stopAnimating()
        loadingIndicator.center = CGPoint(x: self.containerView.bounds.size.width / 2.0, y: self.containerView.bounds.size.height / 2.0)
        self.containerView.addSubview(loadingIndicator)
        return loadingIndicator
    }()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        containerView.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        containerView.layer.cornerRadius = 5
        self.addSubview(containerView)
        return containerView
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        containerView.center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    }
    
    /// Start animating the loading view.
    open func startAnimating() {
        self.alpha = 0.0
        self.superview?.addSubview(self)
        self.isHidden = false
        self.loadingIndicator.startAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
        })
    }
    
    /// Stop animating the loading view.
    open func stopAnimating(_ completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
        }, completion: {_ in
            self.isHidden = true
            self.loadingIndicator.stopAnimating()
            completion?()
        })
    }
}
