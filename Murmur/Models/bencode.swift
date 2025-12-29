import Foundation

    // MARK: bencode
    // ##############################
    // bencode.swift
    //
    // defines bencode as an enum type
    // conceptually, this lives here because both decode and encode use bencode
    // practically only decode does, so this could move there
    // originally defined here as it contained a recursive walker but practically
    // works better as an explicit function in decode
    //
    // model was incoming data (from .torrent, tracker or clients) comes in as bencode type
    // decoded to native types, then when sending out to tracker or clients gets reencoded
    // practically data coming in is stream of bytes and only becomes bencode when it's
    // decoded as a union type for arrays and dictionaries
    // bencode type only exists after decoding, and only temporarily
    // ##############################

public enum bencode: Hashable {
    case string(Data)
    case int(Int)
    indirect case list([bencode])
    indirect case dict([String: bencode])
}
