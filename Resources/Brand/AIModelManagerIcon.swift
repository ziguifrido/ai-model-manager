import Foundation

/// Regenerates all icon sizes from the SVG vector master.
///
/// The canonical source is Resources/Brand/AIModelManagerIcon.svg.
/// This script renders it at 1024×1024 via QuickLook, then scales down.
///
/// Usage:
///   swift Resources/Brand/AIModelManagerIcon.swift
///
/// Output: AIModelManager/Assets.xcassets/AppIcon.appiconset/icon_*.png

let projectDir = URL(fileURLWithPath: #file)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

let svgPath = projectDir
    .appendingPathComponent("Resources/Brand/AIModelManagerIcon.svg")
    .path

let outputDir = projectDir
    .appendingPathComponent("AIModelManager/Assets.xcassets/AppIcon.appiconset")
    .path

// Render SVG at 1024×1024 via QuickLook
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/qlmanage")
task.arguments = ["-t", "-s", "1024", "-o", "/tmp", svgPath]
try task.run()
task.waitUntilExit()

let rendered = "/tmp/AIModelManagerIcon.svg.png"

let fm = FileManager.default
guard fm.fileExists(atPath: rendered) else {
    print("ERROR: qlmanage failed to render SVG")
    exit(1)
}

let sizes = [16, 32, 64, 128, 256, 512, 1024]
for size in sizes {
    let out = "\(outputDir)/icon_\(size).png"
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
    proc.arguments = ["-z", "\(size)", "\(size)", rendered, "--out", out]
    try proc.run()
    proc.waitUntilExit()
    print("Generated \(size)×\(size)")
}

// Also copy 1024 master to Brand
let brandDir = projectDir.appendingPathComponent("Resources/Brand/AIModelManagerIcon.png").path
try? fm.removeItem(atPath: brandDir)
try fm.copyItem(atPath: rendered, toPath: brandDir)

print("Done – SVG is the canonical master source")
