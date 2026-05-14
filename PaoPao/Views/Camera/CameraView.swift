import SwiftUI

struct CameraView: View {
    @State var viewModel = CameraViewModel()
    var petAvatarFileName: String = ""
    var onPetSetup: (() -> Void)? = nil
    @State private var showFlash = false
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
            Color(red: 0.98, green: 0.96, blue: 0.93).ignoresSafeArea()

            doodleDecorations

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer().frame(height: 66)

                viewfinder
                    .padding(.horizontal, 20)

                Spacer()

                Text(isRecording ? "松开结束录制" : tipText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.4))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.white.opacity(0.7)))

                Spacer().frame(height: 20)

                ShutterButton(
                    isRecording: isRecording,
                    recordingProgress: viewModel.recordingProgress,
                    onTap: { viewModel.capturePhoto(); triggerFlash() },
                    onLongPressStart: { viewModel.startRecording() },
                    onLongPressEnd: { viewModel.stopRecording() }
                )

                Spacer().frame(height: 36)
            }

            if showFlash {
                Color.white.ignoresSafeArea().transition(.opacity)
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
            Button(action: { onPetSetup?() }) {
                if !petAvatarFileName.isEmpty,
                   let img = loadPetAvatar(petAvatarFileName) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                } else {
                    Text("😺").font(.system(size: 28))
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 18))
                    .foregroundStyle(.black.opacity(0.4))
                    .padding(8)
                    .background(Circle().fill(.white.opacity(0.7)))
            }
        }
    }

    // MARK: - 取景框

    private var viewfinder: some View {
        GeometryReader { geo in
            ZStack {
                #if targetEnvironment(simulator)
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(red: 0.92, green: 0.9, blue: 0.86))
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.black.opacity(0.2))
                            Text("真机预览")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(.black.opacity(0.3))
                        }
                    }
                #else
                CameraPreviewLayer(session: viewModel.session)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                #endif

                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        isRecording ? Color(red: 1.0, green: 0.42, blue: 0.42) : .black.opacity(0.08),
                        style: StrokeStyle(lineWidth: isRecording ? 3 : 2, dash: isRecording ? [] : [10, 6])
                    )
                    .animation(.spring(response: 0.3), value: isRecording)

                cornerStickers(size: geo.size)

                // 小猫趴在相框顶部中央
                Image("CameraOverlay")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.65)
                    .clipShape(Rectangle().offset(y: 0).size(width: geo.size.width, height: geo.size.width * 0.65 * (2080.0/1734.0) * 0.5 - 10))
                    .position(x: geo.size.width / 2, y: geo.size.width * 0.5 * (2080.0/1734.0) * 0.5 - 70)
                    .allowsHitTesting(false)
            }
        }
        .aspectRatio(3.0/4.0, contentMode: .fit)
    }

    // MARK: - 四角贴纸

    private func cornerStickers(size: CGSize) -> some View {
        let inset: CGFloat = 16
        return ZStack {
            Text("⭐️").font(.system(size: 14))
                .offset(x: -(size.width/2 - inset), y: -(size.height/2 - inset))
            Text("🌸").font(.system(size: 14))
                .offset(x: size.width/2 - inset, y: -(size.height/2 - inset))
            Text("🍀").font(.system(size: 14))
                .offset(x: -(size.width/2 - inset), y: size.height/2 - inset)
            Text("✨").font(.system(size: 14))
                .offset(x: size.width/2 - inset, y: size.height/2 - inset)
        }
    }

    // MARK: - 散落装饰

    private var doodleDecorations: some View {
        ZStack {
            Text("~").font(.system(size: 20)).foregroundStyle(.black.opacity(0.06))
                .offset(x: -140, y: -300).rotationEffect(.degrees(-15))
            Text("♪").font(.system(size: 16)).foregroundStyle(.black.opacity(0.06))
                .offset(x: 150, y: -280)
            Text("○").font(.system(size: 24)).foregroundStyle(.black.opacity(0.05))
                .offset(x: -120, y: 320)
            Text("△").font(.system(size: 18)).foregroundStyle(.black.opacity(0.05))
                .offset(x: 140, y: 300)
        }
    }

    // MARK: - 闪光

    private func triggerFlash() {
        withAnimation(.easeIn(duration: 0.05)) { showFlash = true }
        withAnimation(.easeOut(duration: 0.2).delay(0.05)) { showFlash = false }
    }

    private func loadPetAvatar(_ fileName: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
}
