#  Migration Steps -> v3.0


## Search and replace
Use search and replace to update the following method signatures:

### RSDAsyncAction

- Find:
func requestPermissions(on viewController: UIViewController, _ completion: @escaping RSDAsyncActionCompletionHandler)
- Replace:
func requestPermissions(on viewController: Any, _ completion: @escaping RSDAsyncActionCompletionHandler)

### RSDImageWrapper

- Find:
RSDImageWrapper
- Replace:
RSDResourceImageDataObject

- Find:
RSDEmbeddedIconVendor
- Replace: 
RSDEmbeddedIconData

### RSDColorRules

- Find:
RSDColorRules.Style
- Replace:
RSDColorStyle

### RSDStudyConfiguration

- Find:
RSDStudyConfiguration.shared.colorPalette
- Replace:
RSDDesignSystem.shared.colorRules.palette

### RSDImageVendor

- Find:
var imageVendor: RSDImageVendor?
- Replace:
var imageData: RSDImageData?

### RSDResourceTransformer

- Find:
var factoryBundle: Bundle?
- Replace:
var factoryBundle: RSDResourceBundle?


## Protocol Changes

### RSDChoice
Changed from referencing `imageVendor` to `imageData`.

```
/// An icon image that can be used for displaying the choice.
var imageData: RSDImageData? { get }
```

### RSDUIThemeElement
Removed protocol. This was not referenced directly. The `RSDColorMappingThemeElement`, `RSDImageThemeElement`, and `RSDViewThemeElement` now all inherit from `RSDResourceInfo` directly.

### RSDColorMappingThemeElement
Protocol methods changed to *not* directly reference `UIColor`.

```
public protocol RSDColorMappingThemeElement : RSDResourceInfo {
    
    var customColorData: RSDColorData? { get }
    
    func backgroundColorStyle(for placement: RSDColorPlacement) -> RSDColorStyle
}
```

### RSDImageThemeElement
Protocol methods changed to *not* directly reference `UIImage`. Instead, they rely upon implementing the resource info and use the image name to access the images.

```
public protocol RSDImageThemeElement : RSDResourceInfo {
    
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
```

### RSDTaskInfo
Changed from referencing `imageVendor` to `imageData`.

```
/// An icon image that can be used for displaying the choice.
var imageData: RSDImageData? { get }
```

### RSDTaskGroup
Changed from referencing `imageVendor` to `imageData`.

```
/// An icon image that can be used for displaying the choice.
var imageData: RSDImageData? { get }
```

### RSDUIAction
Changed to referencing a string with the icon name instead of the `UIImage`.

```
public protocol RSDUIAction : RSDResourceInfo {
    
    /// The title to display on the button associated with this action.
    var buttonTitle: String? { get }
    
        /// The name of the icon to display on the button associated with this action.
    var iconName: String? { get }
}
```

### RSDDecodableBundleInfo
Changed the protocol to reference the factory bundle as a pointer and added `packageName` to the protocol.

```
/// `RSDDecodableBundleInfo` is a convenience protocol for getting a bundle from a bundle identifier.
public protocol RSDDecodableBundleInfo : Decodable, RSDResourceInfo {
    
    /// The bundle identifier. Decodable identifier that can be used to get the bundle.
    var bundleIdentifier : String? { get }
    
    /// A pointer to the bundle set by the factory (if applicable).
    var factoryBundle: RSDResourceBundle? { get set }
    
    /// The package name (if applicable)
    var packageName: String? { get set }
}
```

### Bundle references
Changed pointers to `Bundle` to instead point to `RSDResourceBundle`. Additionally, all concrete implementations that use this structure changed from `var factoryBundle : Bundle` to `var factoryBundle : RSDResourceBundle`. 

```
/// A resource bundle is used on Apple platforms to point to the `Bundle` for the resource. It is
/// not directly referenced within this framework so as to avoid any Apple-specific resource
/// handling classes.
public protocol RSDResourceBundle : class {
    
    /// The identifier of the bundle within which the resource is embedded on Apple platforms.
    var bundleIdentifier: String? { get }
}

extension Bundle : RSDResourceBundle {
}

extension RSDResourceInfo {
    
    /// The bundle returned for the given `bundleIdentifier` or `factoryBundle` if `nil`.
    public var bundle: Bundle? {
        guard let identifier = bundleIdentifier
            else {
                return self.factoryBundle as? Bundle
        }
        return Bundle(identifier: identifier)
    }
}
```

### RSDImageWrapper and RSDFileWrapper
Both these concrete implementations for handling images have been deprecated and replaced with `RSDResourceImageDataObject`. This replacement object using the same factory bundle and string to get the image from the resources directory. All classes and structs that reference these objects have been replaced with the  `RSDResourceImageDataObject`, which uses the same `Codable` methods.

### RSDTaskMetadata
Requires that the current platform context info is set during startup in order to get the properties that are specific to the platform.

```
if let platformContext = currentPlatformContext {
    self.deviceInfo = platformContext.deviceInfo
    self.deviceTypeIdentifier = platformContext.deviceTypeIdentifier
    self.appName = platformContext.appName
    self.appVersion = platformContext.appVersion
    self.rsdFrameworkVersion = platformContext.rsdFrameworkVersion
}
else {
    self.deviceInfo = "Unknown"
    self.deviceTypeIdentifier = "Unknown"
    self.appName = "Unknown"
    self.appVersion = "Unknown"
    self.rsdFrameworkVersion = "Unknown"
}
```

### RSDAsyncAction and RSDSampleRecorder
Changed the method signature for requesting permissions to be platform agnostic.

```
func requestPermissions(on viewController: Any, _ completion: @escaping RSDAsyncActionCompletionHandler)
```




