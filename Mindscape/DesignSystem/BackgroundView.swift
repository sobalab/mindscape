import SwiftUI

/// The `gradient-circles` layer from Figma, rebuilt in SwiftUI instead of shipping the
/// exported PNGs — three radial gradients fading to clear, hard-light blended over the
/// background gradient, with the same 2pt blur.
///
/// Geometry is expressed in the Figma frame's own coordinates (a 402pt-wide iPhone frame)
/// and scaled to the real screen width, so it holds up across device sizes.
private struct GradientOrbs: View {

    /// Width of the Figma artboard these offsets were measured against.
    private static let designWidth: CGFloat = 402

    private struct Orb {
        let color: Color
        let diameter: CGFloat
        /// Center in artboard coordinates.
        let center: CGPoint
        /// Figma composites these with hard-light on near-opaque layers, which over a
        /// near-black background reads as a soft additive wash. These strengths were
        /// calibrated by sampling the Figma render against ours at each orb's center.
        let strength: Double
    }

    // The `gradient-circles` frame sits at (-203, 23); these centers fold that offset in.
    private static let orbs = [
        Orb(color: .accentCyan,   diameter: 533, center: CGPoint(x:  63.5, y: 516.5), strength: 0.20),
        Orb(color: .accentPurple, diameter: 659, center: CGPoint(x: 258.5, y: 693.5), strength: 0.52),
        Orb(color: .orbLavender,  diameter: 659, center: CGPoint(x: 310.5, y: 352.5), strength: 0.18),
    ]

    /// Figma's hard-light compositing decays much faster than a linear color ramp — a
    /// bright core that falls away quickly. These stops fit the measured curve.
    private static func falloff(_ color: Color, strength: Double) -> Gradient {
        Gradient(stops: [
            .init(color: color.opacity(strength),        location: 0.00),
            .init(color: color.opacity(strength * 0.35), location: 0.35),
            .init(color: color.opacity(strength * 0.06), location: 0.70),
            .init(color: color.opacity(0),               location: 1.00),
        ])
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / Self.designWidth
            ZStack(alignment: .topLeading) {
                ForEach(Array(Self.orbs.enumerated()), id: \.offset) { _, orb in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Self.falloff(orb.color, strength: orb.strength),
                                center: .center,
                                startRadius: 0,
                                endRadius: orb.diameter / 2 * scale
                            )
                        )
                        .frame(width: orb.diameter * scale, height: orb.diameter * scale)
                        .position(x: orb.center.x * scale, y: orb.center.y * scale)
                        .blendMode(.plusLighter)
                }
            }
            .blur(radius: 2)
        }
        .allowsHitTesting(false)
    }
}

/// Every screen in the app sits on this: the base gradient plus the orb layer.
struct MindscapeBackground: View {
    var body: some View {
        Theme.background
            .overlay { GradientOrbs() }
            .ignoresSafeArea()
    }
}

extension View {
    /// Places the shared background behind a screen's content.
    func mindscapeBackground() -> some View {
        self.background { MindscapeBackground() }
    }
}

#Preview {
    Color.clear.mindscapeBackground()
}
