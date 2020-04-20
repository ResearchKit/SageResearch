#  Migration Steps -> v3.3

Default task decoding using `open func decodeTask(from decoder: Decoder) throws -> RSDTask`  and
`RSDTaskObject` are deprecated. Instead, register tasks either by registering your own `GenericSerializer` with 
your factory or by adding your custom tasks to the task serializer. Transformers are all still handled the same way.


For example:

```
class MyFactory : RSDFactory {
    override public init() {
        super.init()
        self.stepSerializer.add(MyCustomStep(identifier: "foo"))
    }
}

class MyCustomTask : AssessmentTaskObject {
    public override class func defaultType() -> RSDTaskType {
        .myCustomTask
    }
    
    override var stepNavigator: RSDStepNavigator { _stepNavigator }
    lazy private var _stepNavigator: MyStepNavigator = {
        var navigator = MyStepNavigator(with: steps)
        return navigator
    }()
}

```
