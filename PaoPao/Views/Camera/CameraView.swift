import SwiftUI

struct CameraView: View {
    @State var viewModel = CameraViewModel()
    @State private var showFlash = false
    @State private var catMood: String = "😺"
    @State private var tipText: String = "记录今天的小确幸"

    private let tips = [
        "记录今天的小确幸",
        "拍下让你微笑的瞬间",
        "今天有什么好事发生？",
        "捕捉一个温暖的画面",
        "这一刻，值得留住"
    ]

    var isRecording: Bool {
        if case .recording = viewModel.captureState { return true }
        return false
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部状态栏
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer().frame(height: 20)

                // 大圆角取景框
                viewfinder
                    .padding(.horizontal, 16)

                Spacer()

                // 底部提示文字
                Text(isRecording ? "松开结束录制" : tipText)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .animation(.easeInOut, value: isRecording)

                Spacer().frame(height: 24)

                // 快门按钮
                ShutterButton(
                    isRecording: isRecording,
                    recordingProgress: viewModel.recordingProgress,
                    onTap: { viewModel.capturePhoto(); triggerFlash() },
                    onLongPressStart: { viewModel.startRecording() },
                    onLongPressEnd: { viewModel.stopRecording() }
                )

                Spacer().frame(height: 40)
            }

            // 拍照闪光效果
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.requestPermission()
            tipText = tips.randomElement() ?? tips[0]
        }
    }

    // MARK: - 顶部栏

    private var topBar: some View {
        HStack {
            // 小猫表情 - 随机变化
            Text(catMood)
                .font(.system(size: 28))
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        catMood = ["😺", "😸", "😻", "🙀", "😽"].randomElement()!
                    }
                }

            Spacer()

            Text("泡泡")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Spacer()

            // 翻转相机按钮
            Button(action: {}) {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    // MARK: - 取景框

    private var viewfinder: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                #if targetEnvironment(simulator)
                // 模拟器占位
                RoundedRectangle(cornerRadius: 40)
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.5))
                            Text("真机预览")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                #else
                CameraPreviewLayer(session: viewModel.session)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                #endif

                // 圆角边框装饰
                RoundedRectangle(cornerRadius: 40)
                    .stroke(
                        LinearGradient(
                            colors: isRecording ?
                                [.pink, .orange, .pink] :
                                [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isRecording ? 3 : 1.5
                    )
                    .animation(.easeInOut(duration: 0.3), value: isRecording)

                // 四角装饰点
                cornerDots(size: size)
            }
        }
        .aspectRatio(3.0/4.0, contentMode: .fit)
    }

    // MARK: - 四角装饰

    private func cornerDots(size: CGSize) -> some View {
        let offset: CGFloat = 20
        let dotSize: CGFloat = 8
        return ZStack {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.6))
                    .frame(width: dotSize, height: dotSize)
                    .offset(
                        x: (i % 2 == 0 ? -1 : 1) * (size.width / 2 - offset),
                        y: (i < 2 ? -1 : 1) * (size.height / 2 - offset)
                    )
            }
        }
    }

    // MARK: - 闪光

    private func triggerFlash() {
        withAnimation(.easeIn(duration: 0.05)) { showFlash = true }
        withAnimation(.easeOut(duration: 0.2).delay(0.05)) { showFlash = false }
    }
}
