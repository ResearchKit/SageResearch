#  Migration Steps -> v2.9


## Search and replace
Use research and replace to update the following method signatures:

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

