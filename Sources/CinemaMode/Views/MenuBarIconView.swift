import SwiftUI

struct MenuBarIconView: View {
    var body: some View {
        Image(systemName: "movieclapper.fill")
            .font(.system(size: 13, weight: .semibold))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(.primary)
            .frame(width: 14, height: 14)
    }
}
