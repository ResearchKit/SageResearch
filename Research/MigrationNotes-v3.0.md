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
