#  Release Notes 

## Version 3.4

No migration should be required. 

This version changes the `RSDTaskResult.stepHistory` to include an instance 
of the step result for *each* display of that step so that there can be duplicates of the same step identifier in the
results.

## Version 3.5

No migration should be required. 

This version introduces `SectionResultObject` and changes the protocol for
`RSDTaskResult` to *not* include the schema, revision, and task run UUID. In actual usage, the top-level task 
conforms to `RSDTaskRunResult` with a read/write `taskRunUUID` that is comparable to the Kotlin native 
implementation of an `AssessmentResultObject`.  This change allows for only including the task run UUID at the
top level of the task result JSON file.


