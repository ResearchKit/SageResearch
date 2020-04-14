#  Migration Steps -> v3.1

This set of deprecations is to support Kotlin native serialization. I've added deprecation warnings and debug print 
warnings where possible. Before migrating to using JsonSwift-Apple, you will need to address all the deprecation
warnings.

## RSDUIStep

Change `text` to `subtitle` or `detail` as appropriate.

In order to support BridgeSDK, AppCore, and ResearchKit, there was some inconsistency in the names used for 
various text elements. These have been replaced with uniform conformance to `ContentNode`.

```
public protocol ContentNode {
    var identifier: String { get }
    var title: String? { get }
    var subtitle: String? { get }
    var detail: String? { get }
    var footnote: String? { get }
}
```

Subsequently, any reference to `text` in your code will need to change to look for either `subtitle` or `detail` 
as appropriate. Likewise, `RSDUIStepObject` decoding must replace the "text" keyword with either "subtitle" 
or "detail". In ResearchUI, the `UILabel`  that was mapped to `text` will now map to `subtitle`.

## RSDAnswerResult

In a future version, the `RSDResult` protocol will be replaced with the `Result` protocol. For this version, 
`RSDAnswerResult` is deprecated and replaced with `AnswerResult`. Likewise, `RSDAnswerResultObject` has
been deprecated in favor of `AnswerResultObject`. Eventually, this will mean that results will *not* require a 
`startDate` and `endDate` for all results. They will still require `identifier` and `type` since those are used in 
serialization and in finding the result for a matching step.

The `RSDAnswerResultType` has been replaced with `AnswerType` which is a protocol that conforms to the 
polymorphic serialization pattern used by Kotlin and `RSDFactory`. Additionally, the `jsonValue` replaces the 
`value` as the `Codable` object that is used to store the value.




