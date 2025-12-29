import CryptoKit
import Foundation

    // MARK: torrent
    // ##############################
    // torrent.swift
    //
    // defines a torrent object that reads from a .torrent object
    // TODO: or a magnet link
    // and decodes the bencoded stream into a struct with fields
    // corresponding to bencode dictionary objects
    // ##############################

public enum MetadataError: Error {
    case invalidInfoDictionary
    case invalidBencode
    case unencodeableInfoDict
    case metadataMissingAnnounce
    case metadataMissingName
    case metadataMissingPieces
    case metadataMissingPieceLength
    case noInfoDict
    case invalidFileLength
    case invalidFilePath
}

public class Torrent {
    public let announce: String
    public let announceList: [[String]]?
    public let comment: String?
    public let creationDate: Int?
    public let createdBy: String?
    public let length: Int?
    public let name: String
    public let pieceLength: Int
    public let pieces: Data
    public let isPrivate: Bool?
        // TODO: implement files as struct and build a Files struct in initialiser
    public let files: [fileList]?
    public let encoding: String?
    public let infoHash: Data
    public let bencodedInfoDict: Data
    
    public init(path: String) throws {
            // read torrent file
        let url = URL(fileURLWithPath: path)
        let fileData = (try? Data(contentsOf: url)) ?? Data()
        var infoRange: Range<Int>? = nil
        
        let decoded = try decode(data: fileData, infoRange: &infoRange)
        
        guard let infoRange = infoRange else {
            throw MetadataError.invalidInfoDictionary
        }
        
        let rawInfoBytes = fileData[infoRange]
        
        bencodedInfoDict = rawInfoBytes
        let infoHashData = Insecure.SHA1.hash(data: bencodedInfoDict)
        infoHash = Data(infoHashData)
        
        guard case let .dict(dict) = decoded else { throw MetadataError.invalidBencode }
        
        guard case let .string(announceData) = dict["announce"],
              let announceString = String(data: announceData, encoding: .utf8) else {
            throw MetadataError.metadataMissingAnnounce
        }
        announce = announceString
        
        if let rawAnnounceList = dict["announce-list"],
           case let .list(outerList) = rawAnnounceList {
            self.announceList = outerList.compactMap { innerBencode in
                guard case let .list(innerList) = innerBencode else { return nil }
                let trackers = innerList.compactMap { item -> String? in
                    guard case let .string(data) = item else { return nil }
                    return String(data: data, encoding: .utf8)
                }
                return trackers.isEmpty ? nil : trackers
            }
        } else {
            self.announceList = nil
        }
        
        if case let .string(commentData) = dict["comment"] {
            self.comment = String(data: commentData, encoding: .utf8)
        } else {
            self.comment = nil
        }
        
        if case let .int(creationDateData) = dict["creation date"] {
            self.creationDate = creationDateData
        } else {
            self.creationDate = nil
        }
        
        if case let .string(createdByData) = dict["created by"] {
            self.createdBy = String(data: createdByData, encoding: .utf8)
        } else {
            self.createdBy = nil
        }
        
        guard case let .dict(infoDict) = dict["info"] else {
            throw MetadataError.noInfoDict
        }
        
        guard case let .string(nameData) = infoDict["name"],
              let nameString = String(data: nameData, encoding: .utf8) else {
            throw MetadataError.metadataMissingName
        }
        self.name = nameString
        
        guard case let .string(pieceData) = infoDict["pieces"] else {
            throw MetadataError.metadataMissingPieces
        }
        self.pieces = pieceData
        
        if case let .int(lengthData) = infoDict["length"] {
            self.length = lengthData
        } else {
            self.length = nil
        }
        
        guard case let .int(pieceLengthData) = infoDict["piece length"] else {
            throw MetadataError.metadataMissingPieces
        }
        self.pieceLength = pieceLengthData
        
        if case let .int(isPrivateFlag) = infoDict["private"] {
            if isPrivateFlag == 1 {
                self.isPrivate = true
            } else {
                self.isPrivate = false
            }
        } else {
            self.isPrivate = false
        }
        
        if let filesBencode = infoDict["files"], case let .list(filesArray) = filesBencode {
            
            var result: [fileList] = []
            
            for fileBencode in filesArray {
                    // Each file must be a dictionary
                guard case let .dict(fileDictBencode) = fileBencode else { continue }
                
                    // Convert Bencode dictionary keys (.string(Data)) to String
                var fileDict: [String: bencode] = [:]
                for (key, value) in fileDictBencode {
                    fileDict[key] = value
                }
                
                    // Pass to your fileList initializer
                let file = try fileList(dict: fileDict)
                result.append(file)
            }
            
            self.files = result
        } else {
            self.files = nil // single-file torrent
        }
        
        if case let .string(encodingData) = dict["encoding"] {
            self.encoding = String(data: encodingData, encoding: .utf8)
        } else {
            self.encoding = nil
        }
        
    }
    
        //    public static func == (lhs: Torrent, rhs: Torrent) -> Bool {
        //        lhs.infoHash == rhs.infoHash
        //    }
    
        //    private static func getInfoHash(data: Data) -> Data {
        //        Data(Insecure.SHA1.hash(data: data))
        //    }
        //
        //
        //    private func bencodeInfoDict() -> Data {
        //        var infoDict: Data = Data()
        //        do {
        //            infoDict = try encode(data: getInfoDict())
        //        } catch {
        //            print(error)
        //        }
        //        return infoDict
        //    }
    
    public struct fileList {
        public let length: Int
        public let path: [String]
        
        public init(dict: [String: bencode]) throws(MetadataError) {
            guard let lengthBencode = dict["length"],
                  case let .int(length) = lengthBencode else {
                throw MetadataError.invalidFileLength
            }
            self.length = length
            
                // Extract path
            guard let pathBencode = dict["path"],
                  case let .list(pathArray) = pathBencode else {
                throw MetadataError.invalidFilePath
            }
            
            let pathStrings = pathArray.compactMap { item -> String? in
                guard case let .string(data) = item else { return nil }
                return String(data: data, encoding: .utf8)
            }
            
            guard !pathStrings.isEmpty else {
                throw MetadataError.invalidFilePath
            }
            
            self.path = pathStrings
        }
    }
}
