# SageResearch

[Sage Bionetworks](http://sagebionetworks.org) has spent four years developing mobile health study apps and played a role in supporting over 20 projects, using Research Kit as the basis for all of our iPhone development. Based on that experience, we have begun to generate a next-generation framework and are looking for the involvement of the broader Research Kit community to provide input on design goals and approaches, and contribute to development. This framework:

- Keeps what is good and useful about ResearchKit, provides for a smooth transition from it, and allows ResearchKit 1.x components to be used as modules in Research apps;
- Is based on modern technology (Swift 5);
- Allows maximum flexibility in extending the core step/task navigation and results gathering functionality by defining a set of protocols and then providing a set of classes as concrete reference implementations;
- Allows maximum flexibility in UI/UX design, first by separating generic UX logic control from platform-specific UI implementations, and also again by providing protocols and concrete reference implementations of those protocols;
- Reduces app size and dependency on unused parts of the underlying OS (e.g., permissions strings required in Info.plist files) by separating specific active tasks or logical groups of tasks into their own modules, in general (but not necessarily) built on these two frameworks;
- Is designed with parallel development for other (mobile and web) platforms in mind so that the broadest spectrum of study participants can be reached with the minimum coding effort.

Like ResearchKit, this project is independent of any particular back-end service used to collect study data, record consent, or perform other centralized study functions. Sage Bionetworks is also the lead developer of [Bridge Server](http://developer.sagebridge.org), an open source set of services and SDKs for supporting mHealth research.

This project represents the results to date and the ongoing implementation of those goals.

## Research Module
Research contains the core logic for navigating Steps and Tasks to collect Results independently of any particular UI/UX implementation or back-end services. Key elements of this project are updating code to Swift 4 and creating a data model built around protocols, allowing the more modular composition of apps from independent components.

### Overview

The Research framework is organized into groups for Model, Controller, DataSource, Permissions, Localization, Serialization, and Utilities. For the Model, Controller, and DataSource groups, there is a further division into Protocol and Objects where the Protocol group includes the definitions for the the protocols used throughout this framework and the Object group includes concrete, serializable implementations for those protocols.


### Model

The Model group includes the information that is used to run a task and record the results of that task. It is divided into three groups.

1. **Types** includes enums and structs that are used to define various object types.
2. **Protocol** includes all the model protocols defined by the core framework.
3. **Objects** includes implementations for each protocol. All the objects within the core framework conform to the  `Decodable` protocol to allow using JSON serialization to describe the objects. These objects rely heavily upon the `RSDFactory` to determine how the objects should be encoded and decoded for a given application. The `RSDFactory` is a base class with a singleton `shared` property that is defined as read/write.

####  `RSDTask`

The structure of the task protocol is as follows:

- `RSDTask` is the interface for running a task. It includes properties and methods used to define the task flow.
    - `RSDStepNavigator` is the interface for step navigation. This protocol defines methods for vending steps as appropriate.
        - `RSDStep` is the interface that defines a given step in a clinical research protocol.
        - `progress()` returns the progress through the task for a given step with the current result.
    - `RSDAsyncActionConfiguration` is an array of configurations for defining asynchronous actions that run in the background and can continue across step boundaries.
    - `RSDTaskResult` is a sub-protocol of `RSDResult` that includes the results of a given task run.
    
####  `RSDStep`
    
There are three main subprotocols to the `RSDStep` protocol. These have custom handling that is used by the `RSDTaskController` to determine how to navigate a step tree.  These include:

1. `RSDUIStep` is used to define a single "display unit". Depending upon the available real-estate, more than one ui step may be displayed at a time -- for example, on an iPad, you may choose to group a set of questions using a `RSDSectionStep`.
2. `RSDSectionStep` is used to define a set of steps that are a logically grouped set of steps within a larger task. This protocol conforms to the `RSDStep`, `RSDTask`, and `RSDConditionalStepNavigator` protocols.
3. `RSDTaskInfoStep` is used to display information about a task that can be displayed to the user while the task is fetched. This allows for the actual task to be fetched on demand from a web service or resource file.

The `RSDUIStep` protocol is further broken into sub-protocols that define additional step model UI/UX. These include:

1. `RSDActiveUIStep` defines model information for an "active" step. This includes a step duration, `RSDActiveUIStepCommand` options, and spoken instructions. 
2. `RSDTableStep` defines a model that uses a table or collection view presentation with sections and rows.
3. `RSDThemedUIStep` defines additional information such as images, colors, and custom view identifiers.
4. `RSDFormUIStep` defines one or more input fields.

Additionally, both `RSDTask` and `RSDUIStep` inherit from `RSDUIActionHandler` which can be used to define the text, image, and action that would map to a given button. This allows customization of the UI/UX for a given button to be defined either for that specific step or globally for the entire task.

#### `RSDStepNavigator`

The step navigator vends the steps and progress for a task. This framework includes one implementation of the step navigator which is the `RSDConditionalStepNavigator`. The conditional step navigator uses protocol extension to take an ordered list of steps, and check those steps against the input `RSDTaskResult` to determine whether or not a given step should be skipped or if navigation should jump to a different step using the step `identifier`.

For the conditional step navigator, navigation is handled by querying both a list of `RSDTrackingRule` objects defined on `RSDFactory.shared` and by checking the steps for conformance to a set of navigation rules. Specifically, this framework includes:

1. `RSDNavigationRule` returns a next step identifier that is then used to jump within the navigation.
2. `RSDNavigationSkipRule` allows the step to be skipped based on the current task result.
3. `RSDNavigationBackRule` can block backward navigation.
4. `RSDSurveyNavigationStep` implements the logic of the `RSDNavigationRule` by using protocol extension to inspect the task result and compare the answers to a set of `RSDSurveyRule` objects.
5. `RSDCohortNavigationStep` and `RSDCohortAssignmentStep` are used to navigate based on cohorts to which the participant has been added.

The step results of navigating the task are added to the `RSDTaskResult` on the `stepHistory`. Results added to the step history are intended to be added sequentially in the order the steps were displayed to the user. A step result can be any result that conforms to the `RSDResult` protocol. These results should be uniquely defined by their `identifier` which matches the `identifier` for the step.

#### `RSDAsyncActionConfiguration`

`RSDAsyncActionConfiguration` objects define any configuration required for running a background action -- for example, recording motion sensor information or pinging a weather service. Most of the work of setting up and running async actions is left to the specific application.

#### `RSDResult`

The results of running a task are described using `RSDResult` objects. The base protocol requires conformance to the `Encodable` protocol but does *not* require conformance to `Decodable`. This allows using class objects that cannot be extended to conform to the `Decodable` protocol, such as `ORKResult` classes.

There are several protocols that inherit from `RSDResult` that are included in the core framework. These include:

1. `RSDAnswerResult` which is used to describe an answer to an input field question.
2. `RSDCollectionResult` which is used to describe a collection of other results.
3. `RSDErrorResult` which is used to describe a result that ended with an error.
4. `RSDFileResult` which is used to point to a file. This result type is generally used by asynchronous recorders.
5. `RSDNavigationResult` which is used to track custom navigation as a result of user action.
5. `RSDTaskResult` which is used to include all the results for a given task.

### Controller

The default mechanism for running a task is to instantiate a controller that conforms to either `RSDTaskController` or its sub-protocol, `RSDUITaskController`. There are no implementations for either of these protocols included within this framework, although [ResearchUI](../ResearchUI/index.html) project includes `RSDTaskViewController` which is a concrete implementation of `RSDUITaskController` that is designed to be used for iPhone applications.

Once an instance of either `RSDTaskViewController` or `RSDUITaskController` has been instantiated, as part of its setup, it should instantiate a new instance of of  `RSDTaskViewModel` and use that object (and its children) to manage the task state. `RSDUITaskController` is designed to use a protocol extension to manage most of the device-agnostic UX such as determining when to start/stop async actions, and managing step navigation including instantiating a new task path and result for each `RSDSectionStep` and `RSDTaskInfoStep` that is vended to it by the step navigator.

The `RSDUITaskController` does not directly reference the `RSDStepController` and there are no implementations of the step controller that are included in the Research framework. The ResearchUI framework includes `RSDStepViewController` which is the base class implementation that is designed for use by iPhone applications. `RSDStepController` uses the protocol extension to add UX that is device-agnostic.

The `RSDAsyncAction` is a controller that can be used to run the async action associated with a given configuration. Currently, there are two concrete implementations of this protocol included within this framework; both `RSDDistanceRecorder` and `RSDMotionRecorder` are *only* included in the iOS build.

### DataSource

There are two data source protocols included in the core framework which are used to set up a table view or collection view. 

1. `RSDPickerDataSource` describes information that can be used to build a picker UI element.
2. `RSDTableDataSource` is the model for a table view controller. It provides the data source for a `UITableView`, manages and stores answers provided through user input, and updates the `RSDResult` with those answers when they change.

## ResearchUI
ResearchUI contains the logic for UI/UX controllers, and reference implementations of controllers and views. It is designed to allow greater flexibility in the design of UI elements and screen layout, and to more strongly decouple the presentation layer from the underlying data model of the app.

## ResearchMotion
ResearchMotion contains the logic for recording CoreMotion sensor data to a file stream. 

These files are separated out into their own framework so that applications that use Research and ResearchUI are not required to set up capabilities and privacy keys in the info.plist that aren't used by the application.

## ResearchLocation
ResearchLocation contains the logic for recording CoreLocation GPS data to a file stream. 

These files are separated out into their own framework so that applications that use Research and ResearchUI are not required to set up capabilities and privacy keys in the info.plist that aren't used by the application.

## Research_UnitTest
Research-UnitTest is a utility framework designed to allow for unit tests that test navigation and/or localization within a dependant framework that uses the navigation model supported by Research.

## License

Sage Research SDK is available under the BSD license:

Copyright (c) 2017-2020, Sage Bionetworks
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of Sage Bionetworks nor the names of BridgeSDk's
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SAGE BIONETWORKS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
