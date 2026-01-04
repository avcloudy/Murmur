import Foundation

    // MARK: encode
    // ##############################
    // encode.swift
    //
    // currently contains the bencoder
    // but might expand this conceptually to include anything that could be encoded
    // for example representations of binary data, hashes, pieces etc
    // ##############################

enum encodeError: Error {
    case nonBencodeableDataType
    case nonASCIIString(string: String)
    case nonUTF8String(string: String)
    case nonUTF8String(data: Data)
}

public func encode(data: Any) throws -> Data {
    switch data {
    case let s as String: return try encodeString(data: s)
    case let i as Int: return try encodeInt(data: i)
    case let l as [Any]: return try encodeList(data: l)
    case let d as [String: Any]: return try encodeDict(data: d)
    case let b as Data: return try encodeBytes(data: b)
    default: throw encodeError.nonBencodeableDataType
    }
}

    // MARK: Helper functions for encode(data:)
private func encodeString(data: String) throws -> Data {
    guard let stringData = data.data(using: .utf8) else {
        throw encodeError.nonUTF8String(string: data)
    }
    var encodedString = Data()
    encodedString.append(Data("\(stringData.count):".utf8))
    encodedString.append(stringData)
    return encodedString
}

private func encodeInt(data: Int) throws -> Data {
    var encodedString = Data("i".utf8)
    encodedString.append(Data(String(data).utf8))
    encodedString.append(Data("e".utf8))
    return encodedString
}

private func encodeList(data: [Any]) throws -> Data {
    var encodedString = Data("l".utf8)
    for item in data {
        let encodedItem = try encode(data: item)
        encodedString = encodedString + encodedItem
    }
    encodedString.append(Data("e".utf8))
    return encodedString
}

private func encodeDict(data: [String: Any]) throws -> Data {
    var encodedString = Data("d".utf8)
    for (key, value) in data.sorted(by: { $0.key < $1.key }) {
        let encodedKey = try encode(data: key)
        let encodedValue = try encode(data: value)
        encodedString.append(encodedKey)
        encodedString.append(encodedValue)
    }
    encodedString.append(Data("e".utf8))
    return encodedString
}

private func encodeBytes(data: Data) throws -> Data {
    var result = Data()
    result.append(Data("\(data.count):".utf8))
    result.append(data)
    return result
}
