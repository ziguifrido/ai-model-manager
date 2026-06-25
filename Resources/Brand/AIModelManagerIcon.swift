import Foundation
import AppKit

let projectDir = URL(fileURLWithPath: #file)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

let svgPath = projectDir
    .appendingPathComponent("Resources/Brand/AIModelManagerIcon.svg")
    .path

let outputDir = projectDir
    .appendingPathComponent("AIModelManager/Assets.xcassets/AppIcon.appiconset")
    .path

guard let svgData = FileManager.default.contents(atPath: svgPath),
      let img = NSImage(data: svgData) else {
    print("ERROR: could not load SVG")
    exit(1)
}

let sizes = [16, 32, 64, 128, 256, 512, 1024]
for size in sizes {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 32
    ) else {
        print("ERROR: could not create bitmap rep for \(size)×\(size)")
        exit(1)
    }
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    guard let ctx = NSGraphicsContext(bitmapImageRep: rep) else {
        print("ERROR: could not create graphics context for \(size)×\(size)")
        exit(1)
    }
    NSGraphicsContext.current = ctx
    img.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        print("ERROR: could not encode PNG for \(size)×\(size)")
        exit(1)
    }
    let out = "\(outputDir)/icon_\(size).png"
    try pngData.write(to: URL(fileURLWithPath: out))
    print("Generated \(size)×\(size)")
}

// Also copy 1024 master to Brand
let brandPng = projectDir.appendingPathComponent("Resources/Brand/AIModelManagerIcon.png").path
let masterPng = "\(outputDir)/icon_1024.png"
try? FileManager.default.removeItem(atPath: brandPng)
try FileManager.default.copyItem(atPath: masterPng, toPath: brandPng)

print("Done – SVG is the canonical master source")
