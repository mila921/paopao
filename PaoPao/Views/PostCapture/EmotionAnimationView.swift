import SwiftUI

struct EmotionAnimationView: View {
    let type: EmotionType
    @State private var particles: [Particle] = []
    @State private var animate = false

    var body: some View {
        ZStack {
            switch type {
            case .confetti:
                confettiView
            case .bouncingCat:
                bouncingCatView
            case .sparkles:
                sparklesView
            }
        }
        .onAppear {
            generateParticles()
            withAnimation { animate = true }
        }
    }

    // MARK: - 彩带

    private var confettiView: some View {
        GeometryReader { geo in
            ForEach(particles) { p in
                RoundedRectangle(cornerRadius: 2)
                    .fill(p.color)
                    .frame(width: p.size, height: p.size * 2.5)
                    .rotationEffect(.degrees(animate ? p.rotation + 360 : p.rotation))
                    .offset(
                        x: p.x * geo.size.width,
                        y: animate ? geo.size.height + 50 : -50
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeIn(duration: p.duration).delay(p.delay),
                        value: animate
                    )
            }
        }
    }

    // MARK: - 弹跳猫咪

    private var bouncingCatView: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { i in
                Text(["😸", "🎉", "⭐️"][i])
                    .font(.system(size: 50))
                    .offset(y: animate ? 0 : -30)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.3)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.5)
                            .delay(Double(i) * 0.2),
                        value: animate
                    )
            }
        }
    }

    // MARK: - 星星闪烁

    private var sparklesView: some View {
        GeometryReader { geo in
            ForEach(particles) { p in
                Image(systemName: "sparkle")
                    .font(.system(size: p.size))
                    .foregroundStyle(p.color)
                    .offset(
                        x: p.x * geo.size.width,
                        y: p.y * geo.size.height
                    )
                    .scaleEffect(animate ? 1 : 0)
                    .opacity(animate ? 0.8 : 0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6)
                            .delay(p.delay),
                        value: animate
                    )
            }
        }
    }

    private func generateParticles() {
        let colors: [Color] = [.pink, .orange, .yellow, .purple, .mint, .cyan]
        particles = (0..<30).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0.1...0.9),
                size: CGFloat.random(in: 8...20),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                duration: Double.random(in: 1.5...2.5),
                delay: Double.random(in: 0...0.5)
            )
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
    let rotation: Double
    let duration: Double
    let delay: Double
}
