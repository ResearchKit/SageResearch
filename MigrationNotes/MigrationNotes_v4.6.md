#  Migration Steps -> v4.6

Update Swift Package min target and all app min target OS to iOS 14 and macOS 11

```
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v11),
        .iOS(.v14),
    ]
```

