#  Migration Steps -> v4.9

**Implement `FileArchivable` directly**

Replace your implementations of `RSDArchivable` with `FileArchivable`.

For example, replace `RSDArchivable` with `FileArchivable` and replace:

```
    public func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)? {
        let data = try self.jsonEncodedData()
        let manifest = RSDFileManifest(filename: self.fileName,
                                       timestamp: Date(),
                                       contentType: "application/json",
                                       identifier: self.identifier,
                                       stepPath: stepPath,
                                       jsonSchema: jsonSchemaURL)
        return (manifest, data)
    }
```

with:

```
    public func buildArchivableFileData(at stepPath: String?) throws -> (fileInfo: FileInfo, data: Data)? {
        let data = try self.jsonEncodedData()
        let manifest = FileInfo(filename: self.fileName,
                                timestamp: Date(),
                                contentType: "application/json",
                                identifier: self.identifier,
                                stepPath: stepPath,
                                jsonSchema: jsonSchemaURL)
        return (manifest, data)
    }

```

