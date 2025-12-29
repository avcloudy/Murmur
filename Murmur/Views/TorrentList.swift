import SwiftUI

// TODO: Need to do some thinking about this
// for instance, need to preserve alternating colours
struct TorrentList: View {
    
    @State public var selectedTorrent: Int? = nil
    @Binding var isControlBarVisible: Bool
    
    var body: some View {
        List {
            if isControlBarVisible {
                Color.clear
                    .frame(height: controlBarHeight + 4)
                    .listRowInsets(EdgeInsets())
            }
            ForEach(0..<500) { index in
                TorrentView(index: index)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(
                        (selectedTorrent == index
                         ? Color.accentColor.opacity(0.25)
                         : index % 2 == 0
                         ? Color.gray.opacity(0.05)
                         : Color.gray.opacity(0.15))
                        .frame(maxWidth: .infinity)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTorrent = index
                    }
            }
            .onDelete { _ in
                // Dummy: show swipe delete, but do nothing
                print("Delete action triggered")
            }
        }
        .frame(maxWidth: .infinity)
        
    }
}
