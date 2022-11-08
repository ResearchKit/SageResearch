//
//  RSDImageThemeElement.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDImageThemeElement` extends the UI step to include an image. 
///
/// - seealso: `RSDAnimatedImageThemeElement`
public protocol RSDImageThemeElement : ResourceInfo {
    
    /// A unique identifier that can be used to validate that the image shown in a reusable view
    /// is the same image as the one fetched.
    var imageIdentifier: String { get }
    
    /// The preferred placement of the image. Default placement is `iconBefore` if undefined.
    var placementType: RSDImagePlacementType? { get }
    
    /// The image size. If `.zero` or `nil` then default sizing will be used.
    var imageSize: RSDSize? { get }
    
    /// The image name for the image to draw. This can be either the name of the first image in an
    /// animated series or the resource name used to fetch the image.
    var imageName: String { get }
}

/// `RSDAnimatedImageThemeElement` defines a series of images that can be animated.
public protocol RSDAnimatedImageThemeElement : RSDImageThemeElement {
    
    /// The animation duration.
    var animationDuration: TimeInterval { get }
    
    /// This is used to set how many times the animation should be repeated where `0` means infinite.
    var animationRepeatCount: Int? { get }
    
    /// The list of the names of the images to animate through in order. If nil, it is assumed that
    /// the `imageData` for this image includes the list of all the images.
    var animationImageNames: [String]? { get }
}
