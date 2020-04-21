#  Migration Steps -> v3.3

## Custom Task

Default task decoding using `open func decodeTask(from decoder: Decoder) throws -> RSDTask`  and
`RSDTaskObject` are deprecated. Instead, register tasks either by registering your own `GenericSerializer` with 
your factory or by adding your custom tasks to the task serializer. Transformers are all still handled the same way.

If you inherit your tasks from `RSDTaskObject` but you are *not* using a custom navigator, then you can just 
change the inheritance from `RSDTaskObject` to `AssessmentTaskObject` and override `defaultType()`
to return a different type. Then in your JSON files, set the "type" keywork to the value specified by your override
of `defaultType()`.  See `RSDMotionTaskObject` for an example.

## Custom Step Navigator

If you are currently overriding the factory method

```
open func decodeStepNavigator(from decoder: Decoder) throws -> RSDStepNavigator
```

to return a custom navigator, then this is a bit more work. In order to inherit from  `AssessmentTaskObject`, 
you will need to override `stepNavigator` to return your custom navigator using lazy initialization.

For example:

```
class MyFactory : RSDFactory {
    override public init() {
        super.init()
        self.taskSerializer.add(MyCustomTask(identifier: "foo"))
    }
}

class MyCustomTask : AssessmentTaskObject {
    public override class func defaultType() -> RSDTaskType {
        .myCustomTask
    }
    
    /// Override the step navigator to vend your own navigator.
    override var stepNavigator: RSDStepNavigator { _stepNavigator }
    lazy private var _stepNavigator: MyStepNavigator = {
        var navigator = MyStepNavigator(with: steps)
        return navigator
    }()
}

```

With the example JSON:

```
{
    "identifier": "foo",
    "type": "myCustomTask",
    "steps": [{
              "identifier": "step1",
              "type": "instruction",
              "title": "Step 1"
              },
              {
              "identifier": "step2",
              "type": "active",
              "title": "Step 2"
              },
              {
              "identifier": "step3",
              "type": "section",
              "steps": [{
                        "identifier": "step1",
                        "type": "instruction"
                        },
                        {
                        "identifier": "step2",
                        "type": "instruction"
                        }]
              }]
}
```

## Custom Decoding

If you have custom decoding then you will need to decode all the properties of both the navigator *and* the 
task into the task and *then* instantiate the navigator using the decoded properties.

```
extension RSDTaskType {
    static let myCustomTask: RSDTaskType = "myCustomTask"
}

struct MyCustomNavigator : RSDConditionalStepNavigator {
    let steps: [RSDStep]
    let value: Int
    var progressMarkers: [String]? { nil }
}

class MyCustomTask : AssessmentTaskObject, Encodable {
    override class func defaultType() -> RSDTaskType {
        .myCustomTask
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case value
    }
    
    public var value: Int = 0
    
    /// Override the step navigator to vend your own navigator.
    override var stepNavigator: RSDStepNavigator { _stepNavigator }
    lazy private var _stepNavigator: MyCustomNavigator = {
        var navigator = MyCustomNavigator(steps: steps, value: value)
        return navigator
    }()
    
    // MARK: Override methods to decode and copy the task.
    
    override func decode(from decoder: Decoder) throws {
        try super.decode(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decodeIfPresent(Int.self, forKey: .value) ?? self.value
    }
    
    override func copyInto(_ copy: AssessmentTaskObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? MyCustomTask else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.value = self.value
    }
    
    // MARK: (Optional) Override the `encode` method *and* add conformance to `Encodable`.
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: .value)
    }
    
    // MARK: (Optional) Override the documentation objects--used to unit test and document.
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }
    
    override open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .value:
            return .init(propertyType: .primitive(.integer))
        }
    }
    
    override class func jsonExamples() throws -> [[String : JsonSerializable]] {
        let jsonA: [String : JsonSerializable] = [
            "identifier": "foo",
            "type": "myCustomTask",
            "value": 5,
            "steps": [
                [ "identifier": "step1",
                  "type": "instruction",
                  "title": "Step 1"],
                [ "identifier": "step2",
                  "type": "instruction",
                  "title": "Step 2"]
            ]
        ]
        return [jsonA]
    }
}

```
