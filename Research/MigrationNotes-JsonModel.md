#  Migration Steps -> JsonModel


## Search and replace
Use search and replace to update the following method signatures:

### Replace the JSON protocol names with the JsonModel names

Do a search and replace on the following:

1. RSDJSONNumber -> JsonNumber
2. RSDJSONValue -> JsonValue
3. RSDJSONSerializable -> JsonSerializable
4. RSDResourceInfo -> ResourceInfo
5. RSDDecodableBundleInfo -> DecodableBundleInfo

Then you will need to import JsonModel for any code files that reference these protocols.

```
import JsonModel
```

### Replace ISO8601 formatters

1. rsd_ISO8601TimestampFormatter -> ISO8601TimestampFormatter
2. rsd_ISO8601DateOnlyFormatter -> ISO8601DateOnlyFormatter
3. rsd_ISO8601TimeOnlyFormatter -> ISO8601TimeOnlyFormatter


### Replace the Documentable protocols

Since this was an internal set of protocols, no changes to frameworks built with Research.framework should
require any updates. That said, this feature is now available for use in testing and documentation.

## `RSDFactory` inherits from `SerializationFactory`

### Search and Replace

1. RSDFactoryDecoder -> FactoryDecoder
2. RSDFactoryEncoder -> FactoryEncoder


