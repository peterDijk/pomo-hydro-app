import SwiftUI
import AppKit

struct MenuBarIconView: View {
    let state: PomodoroState
    let allPaused: Bool

    private let iconWidth: CGFloat = 26
    private let iconHeight: CGFloat = 18

    var body: some View {
        Image(nsImage: renderIcon())
    }

    private func renderIcon() -> NSImage {
        let image = NSImage(size: NSSize(width: iconWidth, height: iconHeight), flipped: false) { rect in
            guard let cgContext = NSGraphicsContext.current?.cgContext else { return false }

            let color = NSColor.black // Template images use black; macOS tints automatically

            let clockRadius: CGFloat = 7
            let clockCenter = CGPoint(x: 9, y: rect.midY)

            // --- Clock circle ---
            let clockRect = CGRect(
                x: clockCenter.x - clockRadius,
                y: clockCenter.y - clockRadius,
                width: clockRadius * 2,
                height: clockRadius * 2
            )
            let clockPath = NSBezierPath(ovalIn: clockRect)

            if allPaused {
                color.setStroke()
                clockPath.lineWidth = 1.5
                clockPath.stroke()
                drawPauseBars(in: cgContext, center: clockCenter, radius: clockRadius, color: color)
            } else {
                switch state {
                case .working:
                    color.setFill()
                    clockPath.fill()
                    // Draw hands as cutouts using .clear blend mode
                    cgContext.setBlendMode(.clear)
                    drawClockHands(in: cgContext, center: clockCenter, radius: clockRadius, color: color)
                    cgContext.setBlendMode(.normal)
                case .shortBreak, .longBreak:
                    color.setStroke()
                    clockPath.lineWidth = 1.5
                    let dashPattern: [CGFloat] = [3, 2]
                    clockPath.setLineDash(dashPattern, count: 2, phase: 0)
                    clockPath.stroke()
                    drawClockHands(in: cgContext, center: clockCenter, radius: clockRadius, color: color)
                case .idle, .autoStartCountdown:
                    color.setStroke()
                    clockPath.lineWidth = 1.5
                    clockPath.stroke()
                    drawClockHands(in: cgContext, center: clockCenter, radius: clockRadius, color: color)
                }
            }

            // --- Waterdrop (always visible, half-overlapping clock right edge) ---
            let dropCenter = CGPoint(x: 19, y: rect.midY)
            drawWaterdrop(in: cgContext, center: dropCenter, height: 11, color: color)

            return true
        }
        image.isTemplate = true
        return image
    }

    private func drawClockHands(in ctx: CGContext, center: CGPoint, radius: CGFloat, color: NSColor) {
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(1.5)
        ctx.setLineCap(.round)

        // Hour hand (~10 o'clock)
        ctx.move(to: center)
        ctx.addLine(to: CGPoint(x: center.x - radius * 0.3, y: center.y + radius * 0.45))
        ctx.strokePath()

        // Minute hand (~12 o'clock)
        ctx.move(to: center)
        ctx.addLine(to: CGPoint(x: center.x, y: center.y + radius * 0.65))
        ctx.strokePath()
    }

    private func drawPauseBars(in ctx: CGContext, center: CGPoint, radius: CGFloat, color: NSColor) {
        ctx.setFillColor(color.cgColor)
        let barWidth: CGFloat = 2
        let barHeight: CGFloat = radius * 0.7
        let gap: CGFloat = 2

        ctx.fill(CGRect(x: center.x - gap - barWidth, y: center.y - barHeight / 2, width: barWidth, height: barHeight))
        ctx.fill(CGRect(x: center.x + gap, y: center.y - barHeight / 2, width: barWidth, height: barHeight))
    }

    private func drawWaterdrop(in ctx: CGContext, center: CGPoint, height: CGFloat, color: NSColor) {
        let dropWidth = height * 0.55
        // Note: NSImage with flipped:false has origin at bottom-left
        let tipY = center.y + height / 2
        let bottomY = center.y - height * 0.3

        ctx.setFillColor(color.cgColor)
        ctx.move(to: CGPoint(x: center.x, y: tipY))
        ctx.addQuadCurve(
            to: CGPoint(x: center.x, y: bottomY),
            control: CGPoint(x: center.x + dropWidth, y: center.y - height * 0.05)
        )
        ctx.addQuadCurve(
            to: CGPoint(x: center.x, y: tipY),
            control: CGPoint(x: center.x - dropWidth, y: center.y - height * 0.05)
        )
        ctx.closePath()
        ctx.fillPath()
    }
}
