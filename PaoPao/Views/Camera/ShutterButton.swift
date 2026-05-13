import SwiftUI

struct ShutterButton: View {
    let isRecording: Bool
    let recordingProgress: Double
    let onTap: () -> Void
    let onLongPressStart: () -> Void
    let onLongPressEnd: () -> Void

    @State private var isPressed = false
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // 外圈进度环
            Circle()
                .stroke(Color.black.opacity(0.15), lineWidth: 6)
                .frame(width: 80, height: 80)

            if isRecording {
                Circle()
                    .trim(from: 0, to: recordingProgress)
                    .stroke(
                        Color(red: 1.0, green: 0.42, blue: 0.42),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: recordingProgress)
            }

            // 内圈按钮
            Circle()
                .fill(isRecording ?
                    AnyShapeStyle(Color(red: 1.0, green: 0.42, blue: 0.42)) :
                    AnyShapeStyle(Color(red: 0.31, green: 0.8, blue: 0.77))
                )
                .frame(width: isRecording ? 40 : 64, height: isRecording ? 40 : 64)
                .scaleEffect(scale)
                .animation(.spring(response: 0.25, dampingFraction: 0.55), value: isRecording)
                .animation(.spring(response: 0.15, dampingFraction: 0.5), value: scale)
        }
        .onTapGesture {
            if !isRecording {
                withAnimation(.spring(response: 0.15)) { scale = 0.85 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.15)) { scale = 1.0 }
                    onTap()
                }
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.3)
                .onEnded { _ in
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onLongPressStart()
                }
                .sequenced(before: DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        if isRecording { onLongPressEnd() }
                    }
                )
        )
    }
}
