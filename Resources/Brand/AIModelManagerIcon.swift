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
    let rep = NSBitmapImageRep(
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
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    img.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    NSGraphicsContext.restoreGraphicsState()

    let pngData = rep.representation(using: .png, properties: [:])!
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
