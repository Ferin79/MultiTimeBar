#!/usr/bin/env swift
//
// Procedurally generates the MultiTime app icon at every size the Mac App
// Store requires, then assembles them into an .icns bundle.
//
// Output:
//   build/icon/AppIcon.iconset/…      per-size PNGs
//   build/icon/AppIcon.icns           packaged icon
//   build/icon/AppIcon-1024.png       master 1024×1024 PNG for App Store Connect
//
// Design: rounded rounded-rect gradient background (indigo → violet) with two
// overlapping analog clock faces to communicate "multi time".
//

import AppKit
import CoreGraphics
import Foundation

let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "build/icon"
let iconsetDir = "\(outputDir)/AppIcon.iconset"

let sizes: [(name: String, px: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func drawClockFace(
    in ctx: CGContext,
    center: CGPoint,
    diameter: CGFloat,
    hourAngle: CGFloat,
    minuteAngle: CGFloat,
    faceColor: CGColor,
    detailColor: CGColor,
    scale: CGFloat
) {
    let radius = diameter / 2

    ctx.setFillColor(faceColor)
    ctx.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: diameter, height: diameter))

    // 12 tick marks — the four cardinal ticks (12/3/6/9) are longer.
    ctx.setStrokeColor(detailColor)
    ctx.setLineWidth(scale * 0.010)
    for i in 0..<12 {
        let angle = CGFloat(i) * .pi / 6.0
        let outerR = radius * 0.92
        let innerR = radius * (i % 3 == 0 ? 0.76 : 0.85)
        let outer = CGPoint(x: center.x + outerR * sin(angle),
                            y: center.y + outerR * cos(angle))
        let inner = CGPoint(x: center.x + innerR * sin(angle),
                            y: center.y + innerR * cos(angle))
        ctx.move(to: outer)
        ctx.addLine(to: inner)
    }
    ctx.strokePath()

    ctx.setStrokeColor(detailColor)
    ctx.setLineCap(.round)

    // Hour hand.
    ctx.setLineWidth(scale * 0.024)
    let hourLen = radius * 0.55
    ctx.move(to: center)
    ctx.addLine(to: CGPoint(x: center.x + hourLen * sin(hourAngle),
                             y: center.y + hourLen * cos(hourAngle)))
    ctx.strokePath()

    // Minute hand.
    ctx.setLineWidth(scale * 0.018)
    let minLen = radius * 0.76
    ctx.move(to: center)
    ctx.addLine(to: CGPoint(x: center.x + minLen * sin(minuteAngle),
                             y: center.y + minLen * cos(minuteAngle)))
    ctx.strokePath()

    // Center hub.
    ctx.setFillColor(detailColor)
    let pin = scale * 0.026
    ctx.fillEllipse(in: CGRect(x: center.x - pin / 2, y: center.y - pin / 2, width: pin, height: pin))
}

func drawIcon(pxSize px: Int) -> NSBitmapImageRep {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: px, pixelsHigh: px,
        bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    defer { NSGraphicsContext.restoreGraphicsState() }
    let nsCtx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = nsCtx
    let ctx = nsCtx.cgContext

    // Rounded-rect gradient background.
    let corner = s * 0.225
    ctx.saveGState()
    ctx.addPath(CGPath(
        roundedRect: CGRect(x: 0, y: 0, width: s, height: s),
        cornerWidth: corner, cornerHeight: corner, transform: nil
    ))
    ctx.clip()

    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.20, green: 0.30, blue: 0.85, alpha: 1),
            CGColor(red: 0.55, green: 0.30, blue: 0.98, alpha: 1)
        ] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: s),
        end: CGPoint(x: s, y: 0),
        options: []
    )
    ctx.restoreGState()

    // Back clock — translucent, offset upper-left, showing 2:45.
    drawClockFace(
        in: ctx,
        center: CGPoint(x: s * 0.36, y: s * 0.62),
        diameter: s * 0.50,
        hourAngle: .pi / 3,
        minuteAngle: -.pi / 2,
        faceColor: CGColor(red: 1, green: 1, blue: 1, alpha: 0.55),
        detailColor: CGColor(red: 0.20, green: 0.10, blue: 0.55, alpha: 0.85),
        scale: s
    )

    // Front clock — main, at 10:10.
    drawClockFace(
        in: ctx,
        center: CGPoint(x: s * 0.60, y: s * 0.42),
        diameter: s * 0.60,
        hourAngle: -.pi / 3,
        minuteAngle: .pi / 3,
        faceColor: CGColor(red: 1, green: 1, blue: 1, alpha: 1),
        detailColor: CGColor(red: 0.10, green: 0.10, blue: 0.22, alpha: 1),
        scale: s
    )

    return rep
}

func writePNG(_ rep: NSBitmapImageRep, to path: String) throws {
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "gen-icon", code: 1, userInfo: [NSLocalizedDescriptionKey: "PNG encode failed"])
    }
    try data.write(to: URL(fileURLWithPath: path))
}

let fm = FileManager.default
try? fm.removeItem(atPath: iconsetDir)
try fm.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

for entry in sizes {
    let rep = drawIcon(pxSize: entry.px)
    try writePNG(rep, to: "\(iconsetDir)/\(entry.name)")
    print("✓ \(entry.name)")
}

let masterRep = drawIcon(pxSize: 1024)
try writePNG(masterRep, to: "\(outputDir)/AppIcon-1024.png")
print("✓ Master 1024×1024 PNG")

let icnsPath = "\(outputDir)/AppIcon.icns"
let task = Process()
task.launchPath = "/usr/bin/iconutil"
task.arguments = ["-c", "icns", iconsetDir, "-o", icnsPath]
try task.run()
task.waitUntilExit()
guard task.terminationStatus == 0 else {
    print("✗ iconutil failed with status \(task.terminationStatus)")
    exit(Int32(task.terminationStatus))
}
print("✓ \(icnsPath)")
