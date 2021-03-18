#   Migration Steps -> v4.0

Moved all the async action background recorders that are used by Sage Bionetworks and that were previously
included in this repository to [MobilePassiveData](https://github.com/Sage-Bionetworks/MobilePassiveData-SDK.git).

The rsd-migration-tool can be used to search/replace *most* of the required code migration. For details
on how to use this tool, see MigrationNotes_v4.1.md

## App-level framework embedding

1. Remove `ExceptionHandler.framework`; this will use the same implementation located in the
`MobilePassiveData` Swift Package.
2. Remove `ResearchMotion` framework; import `MotionSensor`. 
3. Remove `ResearchLocation` framework; import `LocationAuthorization` and/or `DistanceRecorder`. 
4. Replace `ResearchAudioRecorder` framework; import `AudioRecorder`.

Note: As a work-around to embedding these frameworks, I had to include the libraries in the 
`Research.xcodeproj` which means that if you use Carthage dependency management that your apps will be
required to include permission strings in the app `Info.plist` file. - syoung 02/03/2021

## Factory changes

1. Deleted deprecated method `decodeAsyncActionConfiguration()`.
2. RSDFactory inherits from `MobilePassiveDataFactory`.

*Migration Required*: Rename classes and import `MobilePassiveData`

    - RSDAsyncActionType -> AsyncActionType
    - RSDMotionRecorderConfiguration -> MotionRecorderConfigurationObject
    - RSDDistanceRecorderConfiguration -> DistanceRecorderConfigurationObject

## Recorders that inherit from RSDSampleRecorders

*Migration Required*: Rename classes and import `MobilePassiveData`

    - RSDDataLogger -> DataLogger
    - RSDSampleRecorder -> SampleRecorder

## Permissions handling

*Migration Required*: Rename classes and import `MobilePassiveData`

    - RSDAuthorizationStatus -> PermissionAuthorizationStatus
    - RSDAuthorizationAdaptor -> PermissionAuthorizationAdaptor
    - RSDAuthorizationHandler -> PermissionAuthorizationHandler
    - RSDStandardPermissionType -> StandardPermissionType
    - RSDStandardPermission -> StandardPermission
    - RSDPermissionType -> PermissionType
    - RSDPermission -> Permission
    
## Configurations

*Migration Required*: Rename classes and import `MobilePassiveData`

    - RSDPermissionConfiguration -> PermissionConfiguration
    - RSDAsyncActionConfiguration -> AsyncActionConfiguration
    - RSDRecorderConfiguration -> RecorderConfiguration
    - RSDRestartableRecorderConfiguration -> RestartableRecorderConfiguration
    - RSDJSONRecorderConfiguration -> JsonRecorderConfiguration

## Async action controller state handling

Most of the handling of async actions is managed by the `RSDTaskViewModel` and `RSDTaskViewController`
implementations and should be transparent to developers who use this framework. These are the methods and
class names that changed:

*Migration Required*: Rename classes and import `MobilePassiveData`

    - RSDAsyncActionVendor -> AsyncActionVendor
    - RSDAsyncActionCompletionHandler -> AsyncActionCompletionHandler
    - RSDAsyncActionDelegate -> AsyncActionControllerDelegate
    - RSDAsyncActionStatus -> AsyncActionStatus
    - RSDAsyncAction -> AsyncActionController

*Migration Required*: `RSDTaskController` protocol changes

    - Deleted Methods: 
`func startAsyncActions(for controllers: [RSDAsyncAction], showLoading: Bool, completion: @escaping (() -> Void))`

    - Changed Methods:
`func requestPermission(for controllers: [AsyncActionController], path: RSDPathComponent, completion: @escaping (() -> Void))`

## Sound Player

*Migration Required*: Rename classes and import `MobilePassiveData`
    
    - RSDSoundPlayer -> SoundPlayer
    - RSDSound -> SoundFile
    - RSDAudioSoundPlayer -> AudioFileSoundPlayer
    
## Voice Prompts

*Migration Required*: Rename classes and import `MobilePassiveData`

    - RSDVoiceBoxCompletionHandler -> VoicePrompterCompletionHandler
    - RSDVoiceBox -> VoicePrompter
    - RSDSpeechSynthesizer -> TextToSpeechSynthesizer
    
## Audio Session

*Migration Required*: 

1. Replace references to `RSDAudioSessionController` with setting the `AudioSessionSettings` on the 
    `AudioSessionController.shared` singleton. The singleton is used to allow activities within an application 
    to set the category, mode, and options on the `AVAudioSession` without having different audio needs clobber 
    each other. Alternatively, you can implement the `RSDActiveTask` protocol.
    
2. Search and Replace: `RSDBackgroundTask` -> `RSDActiveTask`

## System Clock

Search and Replace: `RSDClock` -> `SystemClock` and import `MobilePassiveData`.


