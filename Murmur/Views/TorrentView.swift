import SwiftUI

struct TorrentView: View {
    // TODO: populate with torrent examples
    @State private var name = "ubuntu-25.10-desktop-amd64.iso.torrent"
    // TODO: implement metric size calculations
    @State private var size = "2.03 GB"
    @State private var uploaded = "479.4 MB"
    @State private var ratio = "0.23"
    let index: Int
    
    var body: some View {
        HStack {
            Image(systemName: "text.document").font(.system(size: 30))
            Spacer()
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text("\(name)").font(.system(size: 12)).fontWeight(.regular)
                HStack {
                    Text("\(size), uploaded \(uploaded) (Ratio: \(ratio))").font(.system(size: 10))
                        .fontWeight(.thin)
                }
                HStack(spacing: 0) {
                    ProgressView(value: 0.95)
                        .progressViewStyle(.linear)  // Ensures a horizontal bar
                        .tint(.accentColor)
                    Spacer()
                    Spacer()
                    Button("resume", systemImage: "arrow.clockwise.circle") {}.frame(width: 10, height: 8)
                    Spacer()
                    Button("inspect", systemImage: "magnifyingglass") {}.frame(width: 10, height: 8)
                    //          Spacer()
                }.buttonStyle(.borderless)
                Text("Downloading from 0 of 0 peers - DL: 0.0 KB/s, UL: 0.0 KB/s").font(.system(size: 10))
                    .fontWeight(.thin)
            }
        }
        
        .frame(height: 65)
    }
}
