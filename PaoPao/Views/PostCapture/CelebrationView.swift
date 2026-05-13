import SwiftUI

struct CelebrationView: View {
    let fileName: String
    let mediaType: MediaType
    let onDone: () -> Void

    @State private var showDoneButton = false
    @State private var emotionType: EmotionType = .confetti
    @State private var titleScale: CGFloat = 0.3
    @State private var subtitleOffset: CGFloat = 20

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.97).ignoresSafeArea()

            // 背景：拍摄的照片
            if mediaType == .photo, let image = loadImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .padding(16)
                    .blur(radius: 1)
                    .opacity(0.5)
            }

            // 情绪动画
            EmotionAnimationView(type: emotionType)
                .allowsHitTesting(false)

            // 中间大文字
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(titleScale)

                Text("太棒了！")
                    .font(.system(size: 36, weight: .heavy, design: .serif))
                    .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.42))
                    .scaleEffect(titleScale)

                Text("又记录了一个美好瞬间")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.5))
                    .offset(y: subtitleOffset)
                    .opacity(subtitleOffset == 0 ? 1 : 0)
            }

            // 完成按钮
            VStack {
                Spacer()
                if showDoneButton {
                    Button(action: onDone) {
                        Text("发布 ✨")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.31, green: 0.8, blue: 0.77))
                            .clipShape(Capsule())
                            .padding(.horizontal, 40)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                Spacer().frame(height: 60)
            }
        }
        .onAppear {
            emotionType = EmotionType.allCases.randomElement() ?? .confetti
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                titleScale = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                subtitleOffset = 0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.5)) {
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
