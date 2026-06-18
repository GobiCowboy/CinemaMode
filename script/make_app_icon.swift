import AppKit
import Foundation

let fm = FileManager.default
let args = CommandLine.arguments
guard args.count >= 2 else {
    fputs("usage: make_app_icon.swift <output-dir>\n", stderr)
    exit(2)
}

let outputDir = URL(fileURLWithPath: args[1], isDirectory: true)
try fm.createDirectory(at: outputDir, withIntermediateDirectories: true)

let iconset = outputDir.appendingPathComponent("AppIcon.iconset", isDirectory: true)
try? fm.removeItem(at: iconset)
try fm.createDirectory(at: iconset, withIntermediateDirectories: true)

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

for (size, name) in sizes {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        continue
    }
    drawIcon(in: ctx, size: CGFloat(size))
    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        continue
    }
    try png.write(to: iconset.appendingPathComponent(name))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconset.path, "-o", outputDir.appendingPathComponent("AppIcon.icns").path]
try process.run()
process.waitUntilExit()
guard process.terminationStatus == 0 else {
    fputs("iconutil failed\n", stderr)
    exit(process.terminationStatus)
}

func drawIcon(in ctx: CGContext, size: CGFloat) {
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)

    let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
    let radius = size * 0.22
    let clipPath = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)

    ctx.saveGState()
    ctx.addPath(clipPath)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bgGradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            CGColor(red: 0.11, green: 0.12, blue: 0.16, alpha: 1),
            CGColor(red: 0.03, green: 0.04, blue: 0.05, alpha: 1)
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

    let haloGradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            CGColor(red: 0.10, green: 0.82, blue: 0.96, alpha: 0.32),
            CGColor(red: 0.10, green: 0.82, blue: 0.96, alpha: 0.00)
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawRadialGradient(
        haloGradient,
        startCenter: CGPoint(x: size * 0.72, y: size * 0.76),
        startRadius: 1,
        endCenter: CGPoint(x: size * 0.72, y: size * 0.76),
        endRadius: size * 0.55,
        options: []
    )

    ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.20))
    ctx.fill(rect.insetBy(dx: size * 0.06, dy: size * 0.06))

    ctx.restoreGState()

    // Accent moon.
    ctx.saveGState()
    ctx.setShadow(offset: .init(width: 0, height: -size * 0.01), blur: size * 0.05, color: CGColor(red: 0.95, green: 0.76, blue: 0.28, alpha: 0.35))
    let moonRect = CGRect(x: size * 0.18, y: size * 0.60, width: size * 0.20, height: size * 0.20)
    ctx.setFillColor(CGColor(red: 0.93, green: 0.76, blue: 0.31, alpha: 0.92))
    ctx.fillEllipse(in: moonRect)
    ctx.setBlendMode(.destinationOut)
    ctx.fillEllipse(in: moonRect.offsetBy(dx: size * 0.06, dy: size * 0.02).insetBy(dx: size * 0.01, dy: size * 0.01))
    ctx.restoreGState()

    // Clapboard body.
    let body = CGRect(x: size * 0.22, y: size * 0.20, width: size * 0.56, height: size * 0.40)
    let bodyPath = CGPath(roundedRect: body, cornerWidth: size * 0.06, cornerHeight: size * 0.06, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: .init(width: 0, height: -size * 0.01), blur: size * 0.04, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.55))
    ctx.addPath(bodyPath)
    ctx.setFillColor(CGColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 0.96))
    ctx.fillPath()
    ctx.restoreGState()

    let top = CGRect(x: size * 0.20, y: size * 0.49, width: size * 0.60, height: size * 0.12)
    let topPath = CGPath(roundedRect: top, cornerWidth: size * 0.05, cornerHeight: size * 0.05, transform: nil)
    ctx.addPath(topPath)
    ctx.setFillColor(CGColor(red: 0.91, green: 0.69, blue: 0.20, alpha: 0.97))
    ctx.fillPath()

    // Clapper stripes.
    for i in 0..<5 {
        let x = size * 0.22 + CGFloat(i) * size * 0.11
        let stripe = CGRect(x: x, y: size * 0.49, width: size * 0.06, height: size * 0.12)
        ctx.saveGState()
        ctx.translateBy(x: x + size * 0.03, y: size * 0.49)
        ctx.rotate(by: -.pi / 9.0)
        ctx.translateBy(x: -(x + size * 0.03), y: -size * 0.49)
        ctx.setFillColor(i % 2 == 0 ? CGColor(red: 0.98, green: 0.96, blue: 0.90, alpha: 0.98) : CGColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 0.98))
        ctx.fill(stripe)
        ctx.restoreGState()
    }

    ctx.setStrokeColor(CGColor(red: 0.96, green: 0.80, blue: 0.38, alpha: 0.30))
    ctx.setLineWidth(size * 0.012)
    ctx.stroke(body.insetBy(dx: size * 0.02, dy: size * 0.02))

    let accentCenter = CGPoint(x: size * 0.72, y: size * 0.32)
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: size * 0.03, color: CGColor(red: 0.10, green: 0.82, blue: 0.96, alpha: 0.55))
    ctx.setFillColor(CGColor(red: 0.10, green: 0.82, blue: 0.96, alpha: 0.95))
    ctx.fillEllipse(in: CGRect(x: accentCenter.x - size * 0.09, y: accentCenter.y - size * 0.09, width: size * 0.18, height: size * 0.18))
    ctx.setFillColor(CGColor(red: 0.03, green: 0.05, blue: 0.07, alpha: 0.96))
    let triangle = CGMutablePath()
    triangle.move(to: CGPoint(x: accentCenter.x - size * 0.03, y: accentCenter.y - size * 0.04))
    triangle.addLine(to: CGPoint(x: accentCenter.x - size * 0.03, y: accentCenter.y + size * 0.04))
    triangle.addLine(to: CGPoint(x: accentCenter.x + size * 0.05, y: accentCenter.y))
    triangle.closeSubpath()
    ctx.addPath(triangle)
    ctx.fillPath()
    ctx.restoreGState()

    let shine = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            CGColor(red: 1, green: 1, blue: 1, alpha: 0.24),
            CGColor(red: 1, green: 1, blue: 1, alpha: 0.00)
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawRadialGradient(
        shine,
        startCenter: CGPoint(x: size * 0.25, y: size * 0.78),
        startRadius: 0,
        endCenter: CGPoint(x: size * 0.25, y: size * 0.78),
        endRadius: size * 0.55,
        options: []
    )
}
