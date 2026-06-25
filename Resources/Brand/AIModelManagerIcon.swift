import AppKit
import CoreGraphics

// ---- Configuration ----
let outputSize: CGFloat = 1024
let scale: CGFloat = 1.0
let baseSize = outputSize * scale

let colorSpace = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(
    data: nil,
    width: Int(baseSize),
    height: Int(baseSize),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

let r = CGRect(x: 0, y: 0, width: baseSize, height: baseSize)
let s = baseSize // shorthand

// ---- Colors ----
let bgTop = CGColor(red: 0.08, green: 0.20, blue: 0.44, alpha: 1)    // deep indigo
let bgBottom = CGColor(red: 0.15, green: 0.32, blue: 0.55, alpha: 1)  // slate blue
let cardColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.92)
let cardAccent = CGColor(red: 0.30, green: 0.60, blue: 0.90, alpha: 1) // accent blue
let nodeColor = CGColor(red: 0.50, green: 0.75, blue: 1.0, alpha: 0.85)
let lineColor = CGColor(red: 0.60, green: 0.80, blue: 1.0, alpha: 0.30)
let shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.15)
let highlightColor = CGColor(red: 0.70, green: 0.88, blue: 1.0, alpha: 0.50)

// ---- Clip to rounded rect (macOS app icon shape) ----
let iconCorner: CGFloat = s * 0.22
let iconPath = CGPath(roundedRect: r, cornerWidth: iconCorner, cornerHeight: iconCorner, transform: nil)
ctx.addPath(iconPath)
ctx.clip()

// ---- Background gradient ----
let gradient = CGGradient(colorsSpace: colorSpace, colors: [bgTop, bgBottom] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])

// ---- Subtle background texture (light hexagonal pattern) ----
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.04))
ctx.setLineWidth(1)
let hexSize: CGFloat = s * 0.07
let hexW = hexSize * sqrt(3)
let hexH = hexSize * 2
for row in -2...12 {
    for col in -2...12 {
        let x = CGFloat(col) * hexW + (row.isMultiple(of: 2) ? 0 : hexW / 2)
        let y = CGFloat(row) * hexH * 0.75
        if x < -hexW || x > s + hexW || y < -hexH || y > s + hexH { continue }
        let cx = x, cy = y
        ctx.move(to: CGPoint(x: cx + hexSize * cos(CGFloat.pi / 6), y: cy + hexSize * sin(CGFloat.pi / 6)))
        for i in 1..<6 {
            let angle = CGFloat.pi / 6 + CGFloat(i) * CGFloat.pi / 3
            ctx.addLine(to: CGPoint(x: cx + hexSize * cos(angle), y: cy + hexSize * sin(angle)))
        }
        ctx.closePath()
        ctx.strokePath()
    }
}

// ---- Card stack (3 layered cards representing model catalog) ----
func drawCard(at yOffset: CGFloat, width: CGFloat, height: CGFloat, corner: CGFloat, alpha: CGFloat, shadowOffset: CGFloat) {
    let cardRect = CGRect(
        x: (s - width) / 2,
        y: (s - height) / 2 + yOffset,
        width: width,
        height: height
    )

    // Shadow
    ctx.saveGState()
    let shadowPath = CGPath(roundedRect: cardRect.offsetBy(dx: 0, dy: shadowOffset), cornerWidth: corner, cornerHeight: corner, transform: nil)
    ctx.setShadow(offset: .zero, blur: s * 0.03, color: shadowColor)
    ctx.addPath(shadowPath)
    ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.1 * alpha))
    ctx.fillPath()
    ctx.restoreGState()

    // Card fill
    let cardPath = CGPath(roundedRect: cardRect, cornerWidth: corner, cornerHeight: corner, transform: nil)
    ctx.addPath(cardPath)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: alpha))
    ctx.fillPath()

    // Subtle stroke
    ctx.addPath(cardPath)
    ctx.setStrokeColor(CGColor(red: 0.50, green: 0.65, blue: 0.90, alpha: alpha * 0.3))
    ctx.setLineWidth(1)
    ctx.strokePath()
}

// Card dimensions (proportions: ~0.64 x 0.52 of icon size)
let cardW = s * 0.64
let cardH = s * 0.50
let cardCorner = s * 0.06

// Bottom card
drawCard(at: s * 0.06, width: cardW, height: cardH, corner: cardCorner, alpha: 0.60, shadowOffset: -s * 0.02)
// Middle card
drawCard(at: s * 0.03, width: cardW, height: cardH, corner: cardCorner, alpha: 0.80, shadowOffset: -s * 0.01)
// Top card
drawCard(at: 0, width: cardW, height: cardH, corner: cardCorner, alpha: 0.95, shadowOffset: 0)

// ---- Content on top card ----
let topCardRect = CGRect(
    x: (s - cardW) / 2,
    y: (s - cardH) / 2,
    width: cardW,
    height: cardH
)
let innerRect = topCardRect.insetBy(dx: s * 0.04, dy: s * 0.04)

// ---- Interconnected AI nodes on the card ----
let nodeRadius: CGFloat = s * 0.032
let nodeCenters: [CGPoint] = [
    CGPoint(x: innerRect.minX + innerRect.width * 0.25, y: innerRect.minY + innerRect.height * 0.40),
    CGPoint(x: innerRect.minX + innerRect.width * 0.50, y: innerRect.minY + innerRect.height * 0.25),
    CGPoint(x: innerRect.minX + innerRect.width * 0.75, y: innerRect.minY + innerRect.height * 0.40),
    CGPoint(x: innerRect.minX + innerRect.width * 0.30, y: innerRect.minY + innerRect.height * 0.70),
    CGPoint(x: innerRect.minX + innerRect.width * 0.70, y: innerRect.minY + innerRect.height * 0.70),
    CGPoint(x: innerRect.minX + innerRect.width * 0.50, y: innerRect.minY + innerRect.height * 0.55),
]

// Connection lines
ctx.setStrokeColor(lineColor)
ctx.setLineWidth(s * 0.006)
for i in 0..<nodeCenters.count {
    for j in (i+1)..<nodeCenters.count {
        let dx = nodeCenters[i].x - nodeCenters[j].x
        let dy = nodeCenters[i].y - nodeCenters[j].y
        let dist = sqrt(dx*dx + dy*dy)
        if dist < innerRect.width * 0.55 {
            ctx.move(to: nodeCenters[i])
            ctx.addLine(to: nodeCenters[j])
            ctx.strokePath()
        }
    }
}

// Subtle hexagon outline behind nodes
let hexNodeSize = s * 0.045
let hexColors = [
    CGColor(red: 0.35, green: 0.55, blue: 0.85, alpha: 0.12),
    CGColor(red: 0.35, green: 0.55, blue: 0.85, alpha: 0.08),
    CGColor(red: 0.35, green: 0.55, blue: 0.85, alpha: 0.15),
    CGColor(red: 0.35, green: 0.55, blue: 0.85, alpha: 0.10),
    CGColor(red: 0.35, green: 0.55, blue: 0.85, alpha: 0.12),
    CGColor(red: 0.35, green: 0.55, blue: 0.85, alpha: 0.10),
]
for (i, center) in nodeCenters.enumerated() {
    ctx.setStrokeColor(hexColors[i])
    ctx.setLineWidth(s * 0.004)
    ctx.move(to: CGPoint(x: center.x + hexNodeSize * cos(CGFloat.pi / 6), y: center.y + hexNodeSize * sin(CGFloat.pi / 6)))
    for k in 1..<6 {
        let angle = CGFloat.pi / 6 + CGFloat(k) * CGFloat.pi / 3
        ctx.addLine(to: CGPoint(x: center.x + hexNodeSize * cos(angle), y: center.y + hexNodeSize * sin(angle)))
    }
    ctx.closePath()
    ctx.strokePath()
}

// Nodes (filled circles)
ctx.setFillColor(nodeColor)
for center in nodeCenters {
    ctx.addEllipse(in: CGRect(x: center.x - nodeRadius, y: center.y - nodeRadius, width: nodeRadius * 2, height: nodeRadius * 2))
    ctx.fillPath()
}

// Inner highlight on nodes
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.30))
for center in nodeCenters {
    ctx.addEllipse(in: CGRect(x: center.x - nodeRadius * 0.40, y: center.y - nodeRadius * 0.40, width: nodeRadius * 0.80, height: nodeRadius * 0.80))
    ctx.fillPath()
}

// ---- Bottom accent bar (like a "shelf" or "base") ----
let barY = topCardRect.maxY + s * 0.02
let barH = s * 0.025
let barW = cardW * 0.70
let barPath = CGPath(roundedRect: CGRect(x: (s - barW) / 2, y: barY, width: barW, height: barH), cornerWidth: barH / 2, cornerHeight: barH / 2, transform: nil)
ctx.addPath(barPath)
ctx.setFillColor(CGColor(red: 0.40, green: 0.65, blue: 0.95, alpha: 0.25))
ctx.fillPath()

// ---- Light reflection / glass highlight ----
let highlightPath = CGPath(roundedRect: CGRect(x: s * 0.06, y: s * 0.06, width: s * 0.38, height: s * 0.18),
                           cornerWidth: s * 0.03, cornerHeight: s * 0.03, transform: nil)
ctx.addPath(highlightPath)
ctx.setFillColor(highlightColor)
ctx.fillPath()

// ---- Generate image ----
let cgImage = ctx.makeImage()!
let bitmap = NSBitmapImageRep(cgImage: cgImage)
let png = bitmap.representation(using: .png, properties: [:])!

let outputURL = URL(fileURLWithPath: "/tmp/icon_1024.png")
try png.write(to: outputURL)
print("Created \(outputURL.path) (\(png.count) bytes)")
