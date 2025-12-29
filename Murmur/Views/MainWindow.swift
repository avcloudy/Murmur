import SwiftUI

public let defaultOpacity: CGFloat = 0.35
public let darkOpacity: CGFloat = 0.85

struct MainWindowView: View {
    
    @State private var search: String = ""
    @State public var isControlBarVisible: Bool = false
    @State private var isActive: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                TorrentList(isControlBarVisible: $isControlBarVisible)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if isControlBarVisible {
                    ControlRow()
                        .id("ControlRow")
                        .background(.ultraThinMaterial.opacity(0.15))
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                }
            }
        }
        .frame(maxWidth: .infinity).toolbar(removing: .title)
        .toolbarBackground(.ultraThinMaterial.opacity(0.15), for: .windowToolbar)
        //            .toolbarBackgroundVisibility(.visible, for: .windowToolbar)
        .searchable(text: $search)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button("New Torrent", systemImage: "document.badge.plus") {}
                Button("Open Torrent File", systemImage: "folder") {}
                Button("Delete Torrent", systemImage: "circle.slash") {}
                Spacer()
                Toggle("Active", isOn: $isActive).toggleStyle(.switch).controlSize(.regular)
                Spacer()
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Share", systemImage: "pause.circle.fill") {}
                Button("Quick Look", systemImage: "eye") {}
                Button("Inspector", systemImage: "i.circle") {}
                Toggle(
                    "Toggle Control Bar",
                    systemImage: "chevron.up.chevron.down",
                    isOn: Binding(
                        get: { isControlBarVisible },
                        set: { newValue in
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isControlBarVisible = newValue
                                }
                            }
                        }
                    )
                )
                .toggleStyle(.button)
                .accessibilityIdentifier("ControlBarToggle")
                Spacer()
                
            }
        }
    }
}

#Preview {
    MainWindowView()
}
