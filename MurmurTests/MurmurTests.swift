import Testing
import Foundation
import CryptoKit
@testable import Murmur

struct MurmurTests {
    struct MetadataReadTests {
        @Test func metadataReadName() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let nameTest = await torrent.name
            #expect(nameTest == "bbb_sunflower_1080p_60fps_normal.mp4")
        }
        
        @Test func metadataReadAnnounce() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let announceTest = await torrent.announce
            #expect(announceTest == "udp://tracker.openbittorrent.com:80/announce")
        }
        
        @Test func metadataReadAnnounceList() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let announceListTest = await torrent.announceList else { exit(1) }
            #expect(announceListTest == [["udp://tracker.openbittorrent.com:80/announce"], ["udp://tracker.publicbt.com:80/announce"]])
        }
        
        @Test func metadataReadComment() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let commentTest = await torrent.comment else { exit(1) }
            #expect(commentTest == "Big Buck Bunny, Sunflower version")
        }
        
        @Test func metadataReadCreatedBy() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let createdByTest = await torrent.createdBy else { exit(1) }
            #expect(createdByTest == "uTorrent/3320")
        }
        
        @Test func metadataReadCreationDate() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let creationDateTest = await torrent.creationDate else { exit(1) }
            #expect(creationDateTest == 1387308159)
        }
        
        @Test func metadataReadEncoding() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let encodingTest = await torrent.encoding else { exit(1) }
            #expect(encodingTest == "UTF-8")
        }
        
        @Test func metadataReadFiles() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
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
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            guard let lengthTest = await torrent.length else { exit(1) }
            #expect(lengthTest == 355856562)
        }
        
        @Test func metadataReadPieceLength() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let pieceLengthTest = await torrent.pieceLength
            #expect(pieceLengthTest == 524288)
        }
    }
    
    struct InfoDictTests {
        @Test func infoDictMatches() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
            let bencodedInfoDict = await torrent.bencodedInfoDict
            let hardcodedInfoDict = "d13:file-durationli634ee10:file-mediali0ee5:filesld6:lengthi1234e4:pathl9:file1.txteed6:lengthi5678e4:pathl9:file2.txt10:.gitignoreeee6:lengthi355856562e4:name36:bbb_sunflower_1080p_60fps_normal.mp412:piece lengthi524288e6:pieces4:test8:profilesld6:acodec0:6:heighti1080e6:vcodec4:AVC15:widthi1920eeee".data(using: .utf8)
            #expect(bencodedInfoDict == hardcodedInfoDict)
        }
        
        @Test func infoDictHashMatches() async throws {
            let torrent = try await Torrent(path: "/Users/cloudy/Downloads/testtorrents/sunflower.torrent")
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

}
