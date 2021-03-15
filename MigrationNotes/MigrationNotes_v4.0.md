#  Migration Steps -> v4.0

The first step in migrating your code is to run the migration tool. This will update *most* of the required 
changes. Additionally, the following manual steps are also required:

## `RSDResult` protocols renamed and moved to `JsonModel`

1. `RSDResult` replaced with `ResultData`
2. `AnswerResult` moved to JsonModel
3. `CollectionResult` moved to JsonModel and `inputResults` renamed as `children`.
4. `RSDFileResult` replaced with `FileResult`
5. `RSDErrorResult` replaced with `ErrorResult`

### Result `type` keyword changed

The `type` keyword for the result has been changed to `serializableType` and the struct type
has been changed from `RSDResultType` to `SerializableResultType`. Additionally, to allow
for different serialization strategies to be used to archive and upload the results to Bridge, the 
base protocol of `ResultData` does **not** require conformance to `SerializableResultData`.
Since the `type` keyword is difficult to replace using automated search and replace rules, the 
migration tool does not do so *except* within the structs or classes that define it.

### `RSDTaskRunResult` is deprecated. 

Use `AssessmentResult` directly and encode the `assessmentIdentifier`, `schemaIdentifier`, 
and `versionString` directly if these values are encoded by your top-level task result.

### Implement `deepCopy()` method on all results

This has been added to allow for results that store collections of other results to explicitly **copy** 
the child results since it cannot be guaranteed that those results are stucts rather than classes.

See `FileResultObject`, `AnswerResultObject`, and `CollectionResultObject` for examples 
of appropriate implementions.

## Deprecated methods and classes have been deleted

Any references to deprecated methods, classes, and protocols will fail. These need to be refactored
before migrating to version 4.0.

