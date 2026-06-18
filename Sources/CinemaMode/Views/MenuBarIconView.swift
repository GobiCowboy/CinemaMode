import AppKit
import SwiftUI

struct MenuBarIconView: View {
    var body: some View {
        icon
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
    }

    private var icon: Image {
        if let image = appIconImage {
            return Image(nsImage: image).renderingMode(.original)
        }
        return Image(systemName: "movieclapper")
    }

    private var appIconImage: NSImage? {
        guard let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }
}
