#  Data Model

The `Data Model` group includes a concrete, serializable implementation for all the protocols defined by the interface. This  framework provides a factory for serialization called the `RSDFactory`.  The factory can be subclassed to override the objects returned using a "type" key or it can be extended to include deserialization of other types of objects.

## Types

The `Types` group includes `RawRepresentable`, `Codable` structs that can be used and extended to define the types of objects returned for a given protocol within the `API`.

## Transformers

The `Transformers` group includes deserializable objects that are used to transform JSON or XML serialized objects into objects that map to the API protocols.

## Objects

The `Objects` group includes concrete `Decodable` and `Encodable` implementations for the API protocols.
