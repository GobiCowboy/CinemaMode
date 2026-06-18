import Foundation

public struct FloatingWindowState: Equatable, Sendable {
    public var anchor: FloatingAnchor
    public var opacity: Double
    public var isHovered: Bool
    public var isVisible: Bool
    public var screenIdentifier: String?

    public init(
        anchor: FloatingAnchor = .bottomRight,
        opacity: Double = 0.05,
        isHovered: Bool = false,
        isVisible: Bool = false,
        screenIdentifier: String? = nil
    ) {
        self.anchor = anchor
        self.opacity = opacity
        self.isHovered = isHovered
        self.isVisible = isVisible
        self.screenIdentifier = screenIdentifier
    }

    public func withOpacity(_ opacity: Double) -> FloatingWindowState {
        var copy = self
        copy.opacity = opacity
        return copy
    }

    public func withHover(_ isHovered: Bool) -> FloatingWindowState {
        var copy = self
        copy.isHovered = isHovered
        copy.opacity = isHovered ? 1.0 : copy.opacity
        return copy
    }

    public func withVisibility(_ isVisible: Bool) -> FloatingWindowState {
        var copy = self
        copy.isVisible = isVisible
        return copy
    }
}

