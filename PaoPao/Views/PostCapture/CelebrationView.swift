import SwiftUI

struct CelebrationView: View {
    let fileName: String
    let mediaType: MediaType
    let onDone: () -> Void

    @State private var showDoneButton = false
    @State private var emotionType: EmotionType = .confetti

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // 背景：拍摄的照片
            if mediaType == .photo, let image = loadImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .padding(16)
                    .blur(radius: 2)
                    .opacity(0.6)
            }

            // 情绪动画
            EmotionAnimationView(type: emotionType)
                .allowsHitTesting(false)

            // 中间大文字
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 80))

                Text("太棒了！")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .pink],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("又记录了一个美好瞬间")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }

            // 完成按钮
            VStack {
                Spacer()
                if showDoneButton {
                    Button(action: onDone) {
                        Text("发布 ✨")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .padding(.horizontal, 40)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                Spacer().frame(height: 60)
            }
        }
        .onAppear {
            emotionType = EmotionType.allCases.randomElement() ?? .confetti
            withAnimation(.easeOut(duration: 0.5).delay(2.0)) {
                showDoneButton = true
            }
        }
    }

    private func loadImage() -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
}
