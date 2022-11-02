#  Migration Steps -> v4.7

**Remove all references to deprecated functions and protocols**

The goal of this release is to prepare for migrating SageResearch to a framework 
that can be maintained more easily by deprecating (and deleting in a future version)
the code that is not required to support MobileToolboxKit as the only user that 
is continuing to use the framework.

**Add imported packages to your dependencies**

It is also recommended that you update your package dependencies to include  
`JsonModel` so that SageResearch can point at *all* versions that it supports.

```
    .package(name: "JsonModel",
             url: "https://github.com/Sage-Bionetworks/JsonModel-Swift.git",
             from: "1.6.0"),
```
