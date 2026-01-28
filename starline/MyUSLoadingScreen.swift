import SwiftUI
import Combine

struct MyUSLoadingScreen: View {

    @State private var t: Double = 0
    @State private var pulse: Bool = false
    @State private var sweep: Double = 0
    @State private var drift: Double = 0

    var body: some View {
        ZStack {
            MyUSTheme.background
                .ignoresSafeArea()

            StarMapGrid(t: t)
                .opacity(0.45)
                .blur(radius: 0.4)

            CometStreaks(t: t)
                .blendMode(.screen)
                .opacity(0.7)

            OrbitNodes(t: t, drift: drift)
                .blendMode(.screen)
                .opacity(0.95)

            VStack(spacing: 16) {
                PrismDial(t: t, pulse: pulse, sweep: sweep)
                    .frame(width: 186, height: 186)

                Text("Loading")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(MyUSTheme.textPrimary.opacity(0.90))
                    .scaleEffect(pulse ? 1.02 : 0.98)
                    .opacity(pulse ? 1.0 : 0.84)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
        }
        .onAppear {
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) { t = 1 }
            withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) { pulse = true }
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) { sweep = 1 }
            withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true)) { drift = 1 }
        }
    }
}

private struct StarMapGrid: View {

    let t: Double

    var body: some View {
        GeometryReader { g in
            let s = min(g.size.width, g.size.height)
            let step = max(22, s / 11)
            let phase = t * .pi * 2

            Canvas { ctx, size in
                let cols = Int(size.width / step) + 3
                let rows = Int(size.height / step) + 3

                for r in 0..<rows {
                    for c in 0..<cols {
                        let x = CGFloat(c) * step
                        let y = CGFloat(r) * step

                        let fx = Double(c) * 0.33
                        let fy = Double(r) * 0.27
                        let w = 0.5 + 0.5 * sin(phase + fx + fy)

                        let a = 0.02 + 0.11 * w
                        let glow = Color.white.opacity(a)

                        var p = Path()
                        p.addRoundedRect(
                            in: CGRect(x: x - step * 0.40, y: y - step * 0.40, width: step * 0.80, height: step * 0.80),
                            cornerSize: CGSize(width: 7, height: 7),
                            style: .continuous
                        )
                        ctx.fill(p, with: .color(glow))
                    }
                }

                let starCount = 70
                for i in 0..<starCount {
                    let k = Double(i) / Double(starCount)
                    let px = CGFloat((k * 997).truncatingRemainder(dividingBy: 1.0)) * size.width
                    let py = CGFloat(((k * 613).truncatingRemainder(dividingBy: 1.0))) * size.height

                    let tw = 0.25 + 0.75 * (0.5 + 0.5 * sin(phase * 1.1 + k * 9.0))
                    let a2 = 0.03 + 0.18 * tw
                    let r2 = CGFloat(0.9 + 1.8 * tw)

                    var sp = Path()
                    sp.addEllipse(in: CGRect(x: px - r2, y: py - r2, width: r2 * 2, height: r2 * 2))
                    ctx.fill(sp, with: .color(Color.white.opacity(a2)))
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct CometStreaks: View {

    let t: Double

    var body: some View {
        GeometryReader { g in
            let phase = t - floor(t)
            let w = g.size.width
            let h = g.size.height

            ZStack {
                Comet(stretch: w * 0.42, thickness: 6, x: w * (0.15 + 0.75 * phase), y: h * 0.22, tilt: -18)
                Comet(stretch: w * 0.34, thickness: 5, x: w * (0.85 - 0.75 * phase), y: h * 0.44, tilt: 14)
                Comet(stretch: w * 0.46, thickness: 7, x: w * (0.12 + 0.82 * phase), y: h * 0.74, tilt: -10)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct Comet: View {

    let stretch: CGFloat
    let thickness: CGFloat
    let x: CGFloat
    let y: CGFloat
    let tilt: Double

    var body: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        MyUSTheme.accent.opacity(0.20),
                        MyUSTheme.accentSoft.opacity(0.14),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: stretch, height: thickness)
            .rotationEffect(.degrees(tilt))
            .position(x: x, y: y)
            .blur(radius: 0.6)
    }
}

private struct OrbitNodes: View {

    let t: Double
    let drift: Double

    var body: some View {
        GeometryReader { g in
            let phase = t * .pi * 2
            let w = g.size.width
            let h = g.size.height

            ZStack {
                OrbitBubble(
                    label: "U",
                    a: MyUSTheme.accent,
                    b: MyUSTheme.accentSoft,
                    x: w * 0.18, y: h * 0.22,
                    size: 120,
                    wobble: CGFloat(sin(phase * 0.85)) * 16,
                    drift: CGFloat(cos(drift * .pi * 2)) * 10
                )

                OrbitBubble(
                    label: "S",
                    a: MyUSTheme.mint,
                    b: MyUSTheme.accent,
                    x: w * 0.84, y: h * 0.26,
                    size: 104,
                    wobble: CGFloat(cos(phase * 0.95)) * 14,
                    drift: CGFloat(sin(drift * .pi * 2)) * 12
                )

                OrbitBubble(
                    label: "★",
                    a: MyUSTheme.sun,
                    b: MyUSTheme.accentSoft,
                    x: w * 0.22, y: h * 0.80,
                    size: 112,
                    wobble: CGFloat(sin(phase * 1.10 + 1.1)) * 15,
                    drift: CGFloat(cos(drift * .pi * 2 + 1.6)) * 11
                )

                OrbitBubble(
                    label: "•",
                    a: MyUSTheme.accentSoft,
                    b: MyUSTheme.mint,
                    x: w * 0.80, y: h * 0.78,
                    size: 92,
                    wobble: CGFloat(cos(phase * 1.02 + 0.7)) * 13,
                    drift: CGFloat(sin(drift * .pi * 2 + 2.1)) * 10
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct OrbitBubble: View {

    let label: String
    let a: Color
    let b: Color
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let wobble: CGFloat
    let drift: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            a.opacity(0.70),
                            b.opacity(0.20),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: size * 0.62
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.14), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 24, y: 18)

            Text(label)
                .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.90))
                .shadow(color: Color.white.opacity(0.10), radius: 8)
        }
        .frame(width: size, height: size)
        .position(x: x + wobble + drift, y: y + drift - wobble * 0.18)
        .blur(radius: 0.7)
    }
}

private struct PrismDial: View {

    let t: Double
    let pulse: Bool
    let sweep: Double

    var body: some View {
        GeometryReader { g in
            let s = min(g.size.width, g.size.height)
            let phase = t * .pi * 2
            let p = 0.72 + 0.20 * sin(phase * 0.9)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.10),
                                Color.white.opacity(0.03),
                                Color.black.opacity(0.12)
                            ],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: s * 0.62
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.14), lineWidth: 1.4)
                    )
                    .shadow(color: Color.black.opacity(0.45), radius: 28, y: 18)

                Circle()
                    .stroke(Color.white.opacity(0.07), lineWidth: 10)

                Circle()
                    .trim(from: 0.0, to: CGFloat(max(0.08, min(1.0, p))))
                    .stroke(
                        AngularGradient(
                            colors: [
                                MyUSTheme.accent.opacity(0.95),
                                MyUSTheme.mint.opacity(0.85),
                                MyUSTheme.sun.opacity(0.90),
                                MyUSTheme.accentSoft.opacity(0.82),
                                MyUSTheme.accent.opacity(0.95)
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color.white.opacity(0.16), radius: 10)

                DialTicks(t: t)
                    .padding(18)
                    .opacity(0.88)

                SweepLight(phase: sweep)
                    .frame(width: s, height: s)
                    .clipShape(Circle())
                    .blendMode(.screen)
                    .opacity(0.50)

                VStack(spacing: 6) {
                    Text("LINE")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(MyUSTheme.textPrimary.opacity(0.68))
                        .tracking(2.0)

                    Text("1360")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(MyUSTheme.textPrimary.opacity(0.92))
                        .scaleEffect(pulse ? 1.03 : 0.98)
                }
            }
            .scaleEffect(pulse ? 1.02 : 0.98)
        }
        .allowsHitTesting(false)
    }
}

private struct DialTicks: View {

    let t: Double

    var body: some View {
        let phase = t * .pi * 2

        return Canvas { ctx, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) / 2

            for i in 0..<48 {
                let k = Double(i) / 48.0
                let a = k * .pi * 2
                let m = 0.25 + 0.75 * (0.5 + 0.5 * sin(phase + k * 8.0))

                let len = r * (i % 6 == 0 ? 0.18 : 0.11)
                let w = i % 6 == 0 ? 2.2 : 1.4

                let p0 = CGPoint(x: center.x + CGFloat(cos(a)) * (r - len), y: center.y + CGFloat(sin(a)) * (r - len))
                let p1 = CGPoint(x: center.x + CGFloat(cos(a)) * (r - 2), y: center.y + CGFloat(sin(a)) * (r - 2))

                var path = Path()
                path.move(to: p0)
                path.addLine(to: p1)

                let col = Color.white.opacity(0.10 + 0.22 * m)
                ctx.stroke(path, with: .color(col), lineWidth: w)
            }
        }
    }
}

private struct SweepLight: View {

    let phase: Double

    var body: some View {
        GeometryReader { g in
            let w = g.size.width
            let x = (phase - floor(phase)) * 2.0 - 0.5

            LinearGradient(
                colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.18),
                    Color.white.opacity(0.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: w * 0.26)
            .rotationEffect(.degrees(18))
            .offset(x: CGFloat(x) * w)
            .blur(radius: 2.0)
        }
    }
}
