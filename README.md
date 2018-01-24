# SageResearch-AppleOS

After four years of developing mobile health study apps at Sage Bionetworks based on the ResearchKit framework, the time has come to use what we've learned from that experience to move beyond some of its limitations and quirks, by creating a set of frameworks for building mobile health study apps that:

- Keeps what is good and useful about ResearchKit, and provides for a smooth transition from it;
- Is based on modern technology (Swift 4);
- Allows maximum flexibility in extending the core step/task navigation and results gathering functionality by defining a set of Protocols and then providing a set of classes as concrete reference implementations;
- Allows maximum flexibility in UI/UX design, first by separating generic UX logic control from platform-specific UI implementations, and also again by providing Protocols and concrete reference implementations of those protocols;
- Reduces app size and dependency on unused parts of the underlying OS (e.g., permissions strings required in Info.plist files) by separating specific active tasks or logical groups of tasks into their own modules, in general (but not necessarily) built on these two;
- Is designed with parallel development for other (mobile and stationary) platforms in mind so that the broadest spectrum of study participants can be reached with the minimum coding effort.

This project represents the results to date and the ongoing implementation of those goals.

## Documentation

The core step/task navigation and results-gathering framework is currently called [ResearchSuite](https://erin-mounts.github.io/sageresearch/documentation/researchsuite).

The UI/UX framework is called [ResearchSuiteUI](https://erin-mounts.github.io/sageresearch/documentation/researchsuiteui).

Our first (transitional) app and task module built with these new frameworks is [CRFModuleValidation](https://github.com/Sage-Bionetworks/CRFValidationApp), being used to clinically validate our Cardio-Respiratory Fitness tasks module.

## License

Sage Research SDK is available under the BSD license:

Copyright (c) 2017, Sage Bionetworks
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
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
