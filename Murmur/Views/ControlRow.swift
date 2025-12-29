import SwiftUI

public let controlBarHeight: CGFloat = 14

private enum filterState {
    case all, active, downloading, seeding, paused, error
}

public struct ControlRow: View {
    @State private var filter: filterState = .all
    
    public var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 4) {  // originally 16
                //              Spacer()
                Toggle(
                    "All",
                    isOn: Binding(
                        get: { filter == .all },
                        set: { if $0 { filter = .all } }
                    )
                )
                .toggleStyle(.button)
                .controlSize(.mini)
                Divider()
                Toggle(
                    "Active",
                    isOn: Binding(
                        get: { filter == .active },
                        set: { if $0 { filter = .active } }
                    )
                )
                .toggleStyle(.button)
                .controlSize(.mini)
                Divider()
                Toggle(
                    "Downloading",
                    isOn: Binding(
                        get: { filter == .downloading },
                        set: { if $0 { filter = .downloading } }
                    )
                )
                .toggleStyle(.button)
                .controlSize(.mini)
                Divider()
                Toggle(
                    "Seeding",
                    isOn: Binding(
                        get: { filter == .seeding },
                        set: { if $0 { filter = .seeding } }
                    )
                )
                .toggleStyle(.button)
                .controlSize(.mini)
                Divider()
                Toggle(
                    "Paused",
                    isOn: Binding(
                        get: { filter == .paused },
                        set: { if $0 { filter = .paused } }
                    )
                )
                .toggleStyle(.button)
                .controlSize(.mini)
                Divider()
                Toggle(
                    "Error",
                    isOn: Binding(
                        get: { filter == .error },
                        set: { if $0 { filter = .error } }
                    )
                )
                .toggleStyle(.button)
                .controlSize(.mini)
                
            }
            .frame(height: controlBarHeight)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.thinMaterial)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)
            .accessibilityIdentifier("ControlBarIdentifier")
            Spacer()
            HStack {
                Image(systemName: "arrowshape.down.fill")
                Text("40.0 kbps").font(.caption)
                Image(systemName: "arrowshape.up.fill")
                Text("64.0 kbps").font(.caption)
            }
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.thinMaterial)
            )
            Spacer()
        }
    }
    
}
