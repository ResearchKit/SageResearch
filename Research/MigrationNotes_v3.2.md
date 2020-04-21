#  Migration Steps -> v3.2


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

### Register protocol types

All the decoding methods on `RSDFactory` are deprecated with the exception of decoding a task. If you have a 
custom implementation of any of the protocols supported by the base class using override, these should be 
replaced with registering the object with the appropriate serializer. The pattern used for the serializers is to allow 
adding an example of the given object to the serializer. 

For example:

```
class MyFactory : RSDFactory {
    override public init() {
        super.init()
        self.stepSerializer.add(MyCustomStep(identifier: "foo"))
    }
}

class MyCustomStep : RSDUIStepObject {
    public override class func defaultType() -> RSDStepType {
        .myCustomStep
    }
}

```

Additionally, Kotlin native serialization does *not* support polymorphic serialization of a default type where the 
"type" key is not included. While that path is currently supported by `RSDFactory`, it is deprecated and may be 
removed in a future version of the application.

## Next Up...

In a next step of migration, the `RSDTask` protocol will need to be refactored. The serialization strategy used by 
this framework relies heavily upon the `Decoder.userInfo` and `Encoder.userInfo` properties to allow for 
setting up transformers, resource references, and the factories used to decode an object. This is not available 
using Kotlin native serialization so setting something like that up requires doing things that are hard to document 
and therefore obfuscated. Because of this, with Kotlin support, we moved to a different pattern for the step 
navigators and transformers where they are built on demand and then the state machine is responsible for 
keeping a pointer to the navigator. Additionally, the task will require a one-to-one mapping of the "type" to the
task rather than allowing a default task object to deserialize a typed step navigator. In order to keep the migration 
chunks a bit more managable, that is being broken out into a separate migration effort.
