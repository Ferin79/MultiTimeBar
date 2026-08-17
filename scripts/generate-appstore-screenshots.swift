#!/usr/bin/env swift
// Generates App Store marketing screenshots at 2880x1800 for MultiTimeBar.
// Output: images/appstore/{01-hero,02-menubar,03-dropdown,04-settings,05-time-travel}.png
// No pricing references anywhere in copy (Apple guideline 2.3.7).

import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

// MARK: - Paths

let fm = FileManager.default
let cwd = URL(fileURLWithPath: fm.currentDirectoryPath)
let sourcesDir = cwd.appendingPathComponent("images")
let outDir = cwd.appendingPathComponent("images/appstore")
try? fm.createDirectory(at: outDir, withIntermediateDirectories: true)

// Apple Mac App Store screenshot size (16:10 Retina).
let canvasSize = NSSize(width: 2880, height: 1800)

// MARK: - Helpers

func loadPNG(_ name: String) -> NSImage {
    let url = sourcesDir.appendingPathComponent(name)
    guard let img = NSImage(contentsOf: url) else {
        FileHandle.standardError.write("Missing source image: \(url.path)\n".data(using: .utf8)!)
        exit(1)
    }
    return img
}

func savePNG(_ image: NSImage, to url: URL) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let data = rep.representation(using: .png, properties: [:]) else {
        FileHandle.standardError.write("Failed to encode PNG: \(url.path)\n".data(using: .utf8)!)
        exit(1)
    }
    try? data.write(to: url)
}

// Renders a draw block into a bitmap whose pixel dimensions are EXACTLY `size`
// (Apple requires 2880x1800 for macOS App Store screenshots; NSImage.lockFocus
// on a Retina display would otherwise double the pixel count).
func renderBitmap(size: NSSize, draw: () -> Void) -> NSImage {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    draw()
    NSGraphicsContext.restoreGraphicsState()
    let img = NSImage(size: size)
    img.addRepresentation(rep)
    return img
}

extension NSColor {
    static func hex(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
        NSColor(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: alpha
        )
    }
}

// MARK: - Background

// Modern aurora-style gradient with soft blurred orbs for depth.
func drawBackground(size: NSSize) {
    let ctx = NSGraphicsContext.current!.cgContext

    // Base gradient: deep indigo -> violet -> magenta.
    let colors = [
        NSColor.hex(0x0F1226).cgColor,
        NSColor.hex(0x2A1E67).cgColor,
        NSColor.hex(0x5B2A8A).cgColor,
        NSColor.hex(0x7C2FA0).cgColor
    ]
    let cs = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: [0.0, 0.45, 0.8, 1.0])!
    ctx.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: size.height),
        end: CGPoint(x: size.width, y: 0),
        options: []
    )

    // Soft orbs (blurred radial fills) — draw before content to add depth.
    func orb(x: CGFloat, y: CGFloat, r: CGFloat, color: NSColor) {
        let radial = CGGradient(
            colorsSpace: cs,
            colors: [color.withAlphaComponent(0.55).cgColor, color.withAlphaComponent(0).cgColor] as CFArray,
            locations: [0.0, 1.0]
        )!
        ctx.drawRadialGradient(
            radial,
            startCenter: CGPoint(x: x, y: y), startRadius: 0,
            endCenter: CGPoint(x: x, y: y), endRadius: r,
            options: []
        )
    }

    orb(x: 320, y: size.height - 260, r: 900, color: NSColor.hex(0x4C6FFF))
    orb(x: size.width - 380, y: size.height - 520, r: 780, color: NSColor.hex(0xA060FF))
    orb(x: size.width * 0.72, y: 260, r: 1100, color: NSColor.hex(0xFF4E9C))
    orb(x: 220, y: 220, r: 700, color: NSColor.hex(0x2C5CFF))

    // Subtle top vignette highlight.
    let top = CGGradient(
        colorsSpace: cs,
        colors: [NSColor.white.withAlphaComponent(0.05).cgColor, NSColor.clear.cgColor] as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(
        top,
        start: CGPoint(x: 0, y: size.height),
        end: CGPoint(x: 0, y: size.height * 0.55),
        options: []
    )
}

// MARK: - Text

struct MarketingCopy {
    let title: String
    let subtitle: String
}

func drawMarketingText(_ copy: MarketingCopy, in rect: NSRect) {
    let titleParagraph = NSMutableParagraphStyle()
    titleParagraph.alignment = .center
    titleParagraph.lineSpacing = 4

    let titleFont = NSFont.systemFont(ofSize: 148, weight: .heavy)
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: titleFont,
        .foregroundColor: NSColor.white,
        .paragraphStyle: titleParagraph,
        .kern: -1.5
    ]

    let subtitleParagraph = NSMutableParagraphStyle()
    subtitleParagraph.alignment = .center
    subtitleParagraph.lineSpacing = 6

    let subtitleFont = NSFont.systemFont(ofSize: 54, weight: .regular)
    let subtitleAttrs: [NSAttributedString.Key: Any] = [
        .font: subtitleFont,
        .foregroundColor: NSColor.white.withAlphaComponent(0.82),
        .paragraphStyle: subtitleParagraph
    ]

    let titleStr = NSAttributedString(string: copy.title, attributes: titleAttrs)
    let subtitleStr = NSAttributedString(string: copy.subtitle, attributes: subtitleAttrs)

    // Measure title (may wrap onto multiple lines given font size).
    let titleRect = titleStr.boundingRect(
        with: NSSize(width: rect.width, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
    let subtitleRect = subtitleStr.boundingRect(
        with: NSSize(width: rect.width - 200, height: .greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )

    let totalHeight = titleRect.height + 40 + subtitleRect.height
    let startY = rect.maxY - (rect.height - totalHeight) / 2 - titleRect.height

    let titleDrawRect = NSRect(
        x: rect.minX,
        y: startY,
        width: rect.width,
        height: titleRect.height
    )
    titleStr.draw(in: titleDrawRect)

    let subtitleDrawRect = NSRect(
        x: rect.minX + 100,
        y: startY - 40 - subtitleRect.height,
        width: rect.width - 200,
        height: subtitleRect.height
    )
    subtitleStr.draw(in: subtitleDrawRect)
}

// MARK: - Device / UI frame

func drawUIImage(
    _ image: NSImage,
    centerX: CGFloat,
    baselineY: CGFloat,
    maxWidth: CGFloat,
    maxHeight: CGFloat,
    cornerRadius: CGFloat = 32
) {
    let imgSize = image.size
    let scale = min(maxWidth / imgSize.width, maxHeight / imgSize.height)
    let drawSize = NSSize(width: imgSize.width * scale, height: imgSize.height * scale)
    let drawRect = NSRect(
        x: centerX - drawSize.width / 2,
        y: baselineY,
        width: drawSize.width,
        height: drawSize.height
    )

    let ctx = NSGraphicsContext.current!.cgContext
    ctx.saveGState()

    // Drop shadow beneath the app UI.
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.55)
    shadow.shadowOffset = NSSize(width: 0, height: -18)
    shadow.shadowBlurRadius = 60
    shadow.set()

    // Rounded clip so window chrome corners look crisp.
    let path = NSBezierPath(roundedRect: drawRect, xRadius: cornerRadius, yRadius: cornerRadius)
    path.addClip()

    image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    ctx.restoreGState()
}

// MARK: - Settings image sanitizer
//
// The bundled Settings.png (752x600) shows an in-app footer text
// "Free and open source. Contributions welcome!" which is a price
// reference per Apple guideline 2.3.7. Overlay a matching dark bar +
// clean replacement text before we composite it into the marketing frame.

func sanitizedSettingsImage() -> NSImage {
    let source = loadPNG("Settings.png")
    let size = source.size
    return renderBitmap(size: size) {
        source.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .sourceOver, fraction: 1)

        // Source Settings.png is 752x600. The in-app footer (below the divider)
        // sits at y=78..108 in image coordinates (y-up), containing:
        //   "Free and open source. Contributions welcome!"  (upper)
        //   "github.com/.../MultiTimeInMenuBar"             (lower)
        // Cover the whole band with the window's dark chrome color, then draw
        // clean replacement copy with no price reference.
        let footerRect = NSRect(x: 80, y: 74, width: size.width - 160, height: 38)
        NSColor.hex(0x1F1F22).setFill()
        NSBezierPath(rect: footerRect).fill()

        let footerParagraph = NSMutableParagraphStyle()
        footerParagraph.alignment = .center

        let line1 = NSAttributedString(string: "Open source. Contributions welcome!", attributes: [
            .font: NSFont.systemFont(ofSize: 11, weight: .regular),
            .foregroundColor: NSColor.white.withAlphaComponent(0.65),
            .paragraphStyle: footerParagraph
        ])
        let line2 = NSAttributedString(string: "github.com/Ferin79/MultiTimeBar", attributes: [
            .font: NSFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: NSColor.white.withAlphaComponent(0.55),
            .paragraphStyle: footerParagraph
        ])
        line1.draw(in: NSRect(x: footerRect.minX, y: footerRect.minY + 20, width: footerRect.width, height: 16))
        line2.draw(in: NSRect(x: footerRect.minX, y: footerRect.minY + 4, width: footerRect.width, height: 14))
    }
}

// MARK: - Icon renderer for hero (avoids depending on a rasterized icon file).

func drawHeroIcon(center: NSPoint, size: CGFloat) {
    let ctx = NSGraphicsContext.current!.cgContext
    let rect = NSRect(x: center.x - size / 2, y: center.y - size / 2, width: size, height: size)

    // Shadow.
    ctx.saveGState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.4)
    shadow.shadowOffset = NSSize(width: 0, height: -22)
    shadow.shadowBlurRadius = 60
    shadow.set()

    // Try to use the bundled icon PNG if present for pixel-accurate branding.
    let iconURL = sourcesDir.appendingPathComponent("icon.png")
    if let icon = NSImage(contentsOf: iconURL) {
        let path = NSBezierPath(roundedRect: rect, xRadius: size * 0.22, yRadius: size * 0.22)
        ctx.saveGState()
        path.addClip()
        icon.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
        ctx.restoreGState()
    } else {
        // Fallback: simple squircle with clock glyph.
        let path = NSBezierPath(roundedRect: rect, xRadius: size * 0.22, yRadius: size * 0.22)
        NSColor.hex(0x5B2AE0).setFill()
        path.fill()
    }
    ctx.restoreGState()
}

// MARK: - Screenshot 01: Hero

func renderHero(to url: URL) {
    let image = renderBitmap(size: canvasSize) {
        drawBackground(size: canvasSize)

        let iconSize: CGFloat = 560
        let iconCenter = NSPoint(x: canvasSize.width / 2, y: canvasSize.height * 0.62)
        drawHeroIcon(center: iconCenter, size: iconSize)

        // Title below icon.
        let titleParagraph = NSMutableParagraphStyle()
        titleParagraph.alignment = .center
        titleParagraph.lineSpacing = 6

        let title = NSAttributedString(string: "Every time zone.\nOne glance.", attributes: [
            .font: NSFont.systemFont(ofSize: 192, weight: .heavy),
            .foregroundColor: NSColor.white,
            .paragraphStyle: titleParagraph,
            .kern: -3
        ])
        let titleRect = title.boundingRect(
            with: NSSize(width: canvasSize.width - 200, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        title.draw(in: NSRect(
            x: 100,
            y: iconCenter.y - iconSize / 2 - 80 - titleRect.height,
            width: canvasSize.width - 200,
            height: titleRect.height
        ))

        // Tagline (no price references).
        let subParagraph = NSMutableParagraphStyle()
        subParagraph.alignment = .center
        let sub = NSAttributedString(string: "A beautifully native world clock for your menu bar.", attributes: [
            .font: NSFont.systemFont(ofSize: 60, weight: .regular),
            .foregroundColor: NSColor.white.withAlphaComponent(0.82),
            .paragraphStyle: subParagraph
        ])
        let subRect = sub.boundingRect(
            with: NSSize(width: canvasSize.width - 200, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        sub.draw(in: NSRect(
            x: 100,
            y: iconCenter.y - iconSize / 2 - 80 - titleRect.height - 60 - subRect.height,
            width: canvasSize.width - 200,
            height: subRect.height
        ))
    }
    savePNG(image, to: url)
}

// MARK: - Screenshot 02: Menu bar strip

func renderMenuBar(to url: URL) {
    let image = renderBitmap(size: canvasSize) {
        drawBackground(size: canvasSize)

        let textRect = NSRect(x: 200, y: canvasSize.height * 0.55, width: canvasSize.width - 400, height: 700)
        drawMarketingText(
            MarketingCopy(
                title: "Multiple time zones,\nright in your menu bar.",
                subtitle: "Country flags. Live times. Day-difference indicators — all without leaving the top of your screen."
            ),
            in: textRect
        )

        let bar = loadPNG("menu-bar.png")
        let maxBarWidth = canvasSize.width * 0.72
        drawUIImage(
            bar,
            centerX: canvasSize.width / 2,
            baselineY: 280,
            maxWidth: maxBarWidth,
            maxHeight: 200,
            cornerRadius: 20
        )
    }
    savePNG(image, to: url)
}

// MARK: - Screenshot 03: Dropdown

func renderDropdown(to url: URL) {
    let image = renderBitmap(size: canvasSize) {
        drawBackground(size: canvasSize)

        let textRect = NSRect(x: 200, y: canvasSize.height * 0.62, width: canvasSize.width - 400, height: 620)
        drawMarketingText(
            MarketingCopy(
                title: "Click for the full picture.",
                subtitle: "Live times, dates, and day-difference indicators for every city — always one click away."
            ),
            in: textRect
        )

        let dropdown = loadPNG("menu-bar+dropdown.png")
        drawUIImage(
            dropdown,
            centerX: canvasSize.width / 2,
            baselineY: 140,
            maxWidth: canvasSize.width * 0.55,
            maxHeight: canvasSize.height * 0.6
        )
    }
    savePNG(image, to: url)
}

// MARK: - Screenshot 04: Settings

func renderSettings(to url: URL) {
    let image = renderBitmap(size: canvasSize) {
        drawBackground(size: canvasSize)

        let textRect = NSRect(x: 200, y: canvasSize.height * 0.62, width: canvasSize.width - 400, height: 620)
        drawMarketingText(
            MarketingCopy(
                title: "Add every city that matters.",
                subtitle: "Search any city, reorder with a drag, and tune every detail — 12/24-hour, seconds, flags, and layout."
            ),
            in: textRect
        )

        let settings = sanitizedSettingsImage()
        drawUIImage(
            settings,
            centerX: canvasSize.width / 2,
            baselineY: 140,
            maxWidth: canvasSize.width * 0.6,
            maxHeight: canvasSize.height * 0.6
        )
    }
    savePNG(image, to: url)
}

// MARK: - Screenshot 05: Time travel

func renderTimeTravel(to url: URL) {
    let image = renderBitmap(size: canvasSize) {
        drawBackground(size: canvasSize)

        let textRect = NSRect(x: 200, y: canvasSize.height * 0.62, width: canvasSize.width - 400, height: 620)
        drawMarketingText(
            MarketingCopy(
                title: "Plan across every zone.",
                subtitle: "Drag the Time Travel slider to preview a meeting time in every clock at once. The real time is never changed."
            ),
            in: textRect
        )

        let tt = loadPNG("TimeTravel.png")
        drawUIImage(
            tt,
            centerX: canvasSize.width / 2,
            baselineY: 160,
            maxWidth: canvasSize.width * 0.5,
            maxHeight: canvasSize.height * 0.6
        )
    }
    savePNG(image, to: url)
}

// MARK: - Main

let jobs: [(String, (URL) -> Void)] = [
    ("01-hero.png", renderHero),
    ("02-menubar.png", renderMenuBar),
    ("03-dropdown.png", renderDropdown),
    ("04-settings.png", renderSettings),
    ("05-time-travel.png", renderTimeTravel)
]

for (name, render) in jobs {
    let url = outDir.appendingPathComponent(name)
    render(url)
    print("wrote \(url.path)")
}
