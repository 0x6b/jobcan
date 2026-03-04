#!/usr/bin/swift
import AppKit

let sizes: [(CGFloat, String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

let iconsetPath = "Resources/AppIcon.iconset"
let fm = FileManager.default
try? fm.removeItem(atPath: iconsetPath)
try fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for (size, name) in sizes {
    let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
        NSColor(calibratedRed: 0.2, green: 0.5, blue: 0.9, alpha: 1.0).setFill()
        NSBezierPath(roundedRect: rect, xRadius: size * 0.2, yRadius: size * 0.2).fill()

        let symbolSize = size * 0.75
        let config = NSImage.SymbolConfiguration(pointSize: symbolSize, weight: .medium)
            .applying(.init(paletteColors: [.white]))
        if let symbol = NSImage(systemSymbolName: "suitcase.fill", accessibilityDescription: nil)?
            .withSymbolConfiguration(config) {
            let drawSize = size * 0.7
            let x = (size - drawSize) / 2
            let y = (size - drawSize) / 2
            symbol.draw(in: NSRect(x: x, y: y, width: drawSize, height: drawSize))
        }
        return true
    }

    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    NSGraphicsContext.restoreGraphicsState()

    let data = rep.representation(using: .png, properties: [:])!
    try data.write(to: URL(fileURLWithPath: "\(iconsetPath)/\(name).png"))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetPath, "-o", "Resources/AppIcon.icns"]
try process.run()
process.waitUntilExit()

try fm.removeItem(atPath: iconsetPath)
print("Generated Resources/AppIcon.icns")
