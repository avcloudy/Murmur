import Testing
import Foundation
import CryptoKit
@testable import Murmur

struct MurmurTests {
    struct MetadataReadTests {
        @Test func metadataReadName() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let nameTest = await torrent.name
            #expect(nameTest == "bbb_sunflower_1080p_60fps_normal.mp4")
        }
        
        @Test func metadataReadAnnounce() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let announceTest = await torrent.announce
            #expect(announceTest == "udp://tracker.openbittorrent.com:80/announce")
        }
        
        @Test func metadataReadAnnounceList() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let announceListTest = await torrent.announceList else { exit(1) }
            #expect(announceListTest == [["udp://tracker.openbittorrent.com:80/announce"], ["udp://tracker.publicbt.com:80/announce"]])
        }
        
        @Test func metadataReadComment() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let commentTest = await torrent.comment else { exit(1) }
            #expect(commentTest == "Big Buck Bunny, Sunflower version")
        }
        
        @Test func metadataReadCreatedBy() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let createdByTest = await torrent.createdBy else { exit(1) }
            #expect(createdByTest == "uTorrent/3320")
        }
        
        @Test func metadataReadCreationDate() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let creationDateTest = await torrent.creationDate else { exit(1) }
            #expect(creationDateTest == 1387308159)
        }
        
        @Test func metadataReadEncoding() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let encodingTest = await torrent.encoding else { exit(1) }
            #expect(encodingTest == "UTF-8")
        }
        
        @Test func metadataReadFiles() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let filesList = await torrent.files else { exit(1) }
            let filesList0Length = await filesList[0].length
            let filesList0Path = await filesList[0].path
            let filesList1Length = await filesList[1].length
            let filesList1Path = await filesList[1].path
            #expect(filesList0Length == 1234)
            #expect(filesList0Path == ["file1.txt"])
            #expect(filesList1Length == 5678)
            #expect(filesList1Path == ["file2.txt", ".gitignore"])
        }
        
        @Test func metadataReadLength() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let lengthTest = await torrent.length else { exit(1) }
            #expect(lengthTest == 355856562)
        }
        
        @Test func metadataReadPieceLength() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let pieceLengthTest = await torrent.pieceLength
            #expect(pieceLengthTest == 524288)
        }
    }
    
    struct InfoDictTests {
        @Test func infoDictMatches() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let bencodedInfoDict = await torrent.bencodedInfoDict
            let hardcodedInfoDict = "d13:file-durationli634ee10:file-mediali0ee5:filesld6:lengthi1234e4:pathl9:file1.txteed6:lengthi5678e4:pathl9:file2.txt10:.gitignoreeee6:lengthi355856562e4:name36:bbb_sunflower_1080p_60fps_normal.mp412:piece lengthi524288e6:pieces4:test8:profilesld6:acodec0:6:heighti1080e6:vcodec4:AVC15:widthi1920eeee".data(using: .utf8)
            #expect(bencodedInfoDict == hardcodedInfoDict)
        }
        
        @Test func infoDictHashMatches() async throws {
            let torrent = try await Metadata(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let bencodedInfoDict = await torrent.bencodedInfoDict
            let hardcodedInfoDict = "d13:file-durationli634ee10:file-mediali0ee5:filesld6:lengthi1234e4:pathl9:file1.txteed6:lengthi5678e4:pathl9:file2.txt10:.gitignoreeee6:lengthi355856562e4:name36:bbb_sunflower_1080p_60fps_normal.mp412:piece lengthi524288e6:pieces4:test8:profilesld6:acodec0:6:heighti1080e6:vcodec4:AVC15:widthi1920eeee".data(using: .utf8)
            let HashedInfoDict = Insecure.SHA1.hash(data: bencodedInfoDict)
            let HashedHardcodedDict = Insecure.SHA1.hash(data: hardcodedInfoDict!)
            let infoDictHash = Data(HashedInfoDict)
            let hardcodedHash = Data(HashedHardcodedDict)
            #expect(HashedInfoDict == HashedHardcodedDict)
            #expect(infoDictHash == hardcodedHash)
        }
    }
    
    struct EncodeTests {
        let testString = "This is a string!"
        let testInt = 42
        let testList = ["These", "are", "all", "strings"]
        let testDict: [String: Any] = [
            "Key": "Value",
            "String": "This is a string!",
            "Int": 42,
            "List": ["String", 42, [1, 2]],
            "Dict": ["Key": "Value"]
        ]
        
        @Test func encodeString() async throws {
            let encodedString = try encode(data: testString)
            #expect(encodedString == "17:This is a string!".data(using: .utf8))
        }
        
        @Test func encodeInt() async throws {
            let encodedInt = try encode(data: testInt)
            #expect(encodedInt == "i42e".data(using: .utf8))
        }
        
        @Test func encodeIntZero() async throws {
            let encodedInt = try encode(data: 0)
            #expect(encodedInt == "i0e".data(using: .utf8))
        }
        
        @Test func simpleEncodeList() async throws {
            let encodedList = try encode(data: testList)
            let bencodedList = "l5:These3:are3:all7:stringse".data(using: .utf8)
            #expect(encodedList == bencodedList)
        }
        
        // TODO: Add a bencode checker to encode so that i can add bencode objects directly
        // for now remember: when encoding an object, only use the native data types, dont try to add
        // bencode objects to an array and pass that
        @Test func recursiveEncodeList() async throws {
//            let encodedString = try encode(data: testString)
//            let encodedInt = try encode(data: testInt)
//            let encodedList = try encode(data: testList)
//            let recursiveList = try encode(data: [encodedString, encodedInt, encodedList])
            let recursiveList = try encode(data: [testString, testInt, testList])
            let bencodedList = "l17:This is a string!i42el5:These3:are3:all7:stringsee".data(using: .utf8)
            #expect(recursiveList == bencodedList)
        }
        
        @Test func recursiveEncodeDict() async throws {
            let recursiveDict = try encode(data: testDict)
            let bencodedDict = "d4:Dictd3:Key5:Valuee3:Inti42e3:Key5:Value4:Listl6:Stringi42eli1ei2eee6:String17:This is a string!e"
                .data(using: .utf8)
            #expect(recursiveDict == bencodedDict)
        }
    }

}
