import Foundation

    // MARK: decode
    // ##############################
    // decode.swift
    //
    // functions for bencode decoding
    // ##############################

    // MARK: Error enum
enum bencodeError: Error {
    case badBencodeStart(index: Int)
    case nonASCII
    case streamEmpty
    case malformedString(index: Int)
    case malformedStringLength(index: Int)
    case malformedInt(index: Int)
    case intMissingEnd(index: Int)
    case malformedList(index: Int)
    case malformedDict(index: Int)
    case dictKeyNotString(index: Int)
    case dictKeyNotUnicode(index: Int)
    case dictKeyNotStringWalker
}

    /// Public facing decode function
    /// - Parameter data: Contents of .torrent file loaded as Data
    ///         let fileData = (try? Data(contentsOf: URL(fileURLWithPath: <file/path.torrent>))) ?? Data()
    /// - Throws: Passes on thrown errors from helper functions
    /// - Returns: Bencode object from bencode.swift.
public func decode(data: Data, infoRange: inout Range<Int>?) throws -> bencode {
    let (root, _) = try dechunk(data: data, index: 0, infoRange: &infoRange)
    return root
}

    // MARK: - Helper functions for decode(data: String)
private func dechunk(data: Data, index: Int, infoRange: inout Range<Int>?) throws -> (bencode, Int) {
        // check we aren't at the end of the array, and if we have reached the second last entry and
        // are callign dechunk, must be malformed stream (effectively empty)
    guard index < data.count else { throw bencodeError.streamEmpty }
    let byte = data[index]
    switch byte {
    case 48...57:  // "0"..."9"
        return try decodeString(data: data, index: index, infoRange: &infoRange)
    case 105:  // "i"
        return try decodeInt(data: data, index: index, infoRange: &infoRange)
    case 108:  // "l"
        return try decodeList(data: data, index: index, infoRange: &infoRange)
    case 100:  // "d"
        return try decodeDict(data: data, index: index, infoRange: &infoRange)
    default: throw bencodeError.badBencodeStart(index: index)
    }
}

private func decodeString(data: Data, index: Int, infoRange: inout Range<Int>?) throws -> (bencode, Int) {
        // grab index to mutate
    var index = index
        // bencode string starts with an int, length of the string, then a colon, then the string
        // 24:this is a bencode string
        // so grab the int characters and when next character not int check is colon
    var stringLength = ""
    while index < data.count, data[index] >= 48, data[index] <= 57 {  // "0"..."9"
        stringLength.append(Character(UnicodeScalar(data[index])))
        index += 1
    }
    guard index < data.count else { throw bencodeError.streamEmpty }
    guard data[index] == 58 else {  // ":"
        throw bencodeError.malformedString(index: index)
    }
    index += 1
        // check stringLength can actually cast to Int
    guard let length = Int(stringLength) else {
        throw bencodeError.malformedStringLength(index: index)
    }
    guard index + length < data.count else { throw bencodeError.streamEmpty }
        // make string of characters and advance the index that length
    let stringData = data[index..<index + length]
    index += length
    return (.string(Data(stringData)), index)
}

private func decodeInt(data: Data, index: Int, infoRange: inout Range<Int>?) throws -> (bencode, Int) {
    var index = index
    guard index < data.count else { throw bencodeError.streamEmpty }
        // bencode int starts with an i, contains the number, then ends with an e eg:
        // i45e
    guard data[index] == 105 else { throw bencodeError.malformedInt(index: index) }  // "i" can only get here from dechunk - so next character must be i
    index += 1
    var intChars = ""
    while index < data.count, data[index] >= 48, data[index] <= 57 {  // "0"..."9"
        intChars.append(Character(UnicodeScalar(data[index])))
        index += 1
    }
    guard let int = Int(intChars) else { throw bencodeError.malformedInt(index: index) }
    guard data[index] == 101 else {  // "e"
        throw bencodeError.intMissingEnd(index: index)
    }
    index += 1
    return (.int(int), index)
}

private func decodeList(data: Data, index: Int, infoRange: inout Range<Int>?) throws -> (bencode, Int) {
    var index = index
    guard index < data.count else { throw bencodeError.streamEmpty }
        // bencode list starts with an l, contains any number of bencode string, int, list or dict
        // objects (including none) and ends with an e. No seperators.
    
        // guard data[index] == 108 else { throw bencodeError.malformedList(index: index) } // "l" can't get here
    index += 1
        // check next character is not e, if it is, return an empty bencode list
    var list: [bencode] = []
    while index < data.count, data[index] != 101 {  // "e"
        let (item, newIndex) = try dechunk(data: data, index: index, infoRange: &infoRange)
        list.append(item)
        index = newIndex
    }
    guard index < data.count, data[index] == 101 else {  // "e"
        throw bencodeError.malformedList(index: index)
    }
    index += 1
    return (.list(list), index)
}

private func decodeDict(data: Data, index: Int, infoRange: inout Range<Int>?) throws -> (bencode, Int) {
    var index = index
    guard index < data.count else { throw bencodeError.streamEmpty }
        // bencode dict starts with a d, the key is the next bencode object, which must be a string
        // and the value is the next bencode object, which may be any bencode object
        //  guard stream[index] == "d" else { throw bencodeError.malformedDict(index: index) }
    index += 1
    var dict: [String: bencode] = [:]
    while data[index] != 101 {  // "e"
        let (key, newIndex) = try dechunk(data: data, index: index, infoRange: &infoRange)
        guard case let .string(dataKey) = key else {
            throw bencodeError.dictKeyNotString(index: index)
        }
        guard let stringKey = String(data: dataKey, encoding: .utf8) else {
            throw bencodeError.dictKeyNotUnicode(index: index)
        }
        index = newIndex
        
        let valueStart = index
        let (value, secondNewIndex) = try dechunk(data: data, index: index, infoRange: &infoRange)
        
        if stringKey == "info" {
            infoRange = valueStart..<secondNewIndex
        }
        
        dict[stringKey] = value
        index = secondNewIndex
    }
    guard data[index] == 101 else {  // "e"
        throw bencodeError.malformedDict(index: index)
    }
    index += 1
    return (.dict(dict), index)
}

