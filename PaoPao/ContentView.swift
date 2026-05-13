import SwiftUI
import SwiftData

enum AppScreen: Equatable {
    case camera
    case celebration(fileName: String, mediaType: MediaType)
    case petSetup
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var screen: AppScreen = .camera
    @State private var cameraViewModel = CameraViewModel()

    var body: some View {
        ZStack {
            switch screen {
            case .camera:
                cameraScreen

            case .celebration(let fileName, let mediaType):
                CelebrationView(fileName: fileName, mediaType: mediaType) {
                    publishEntry(fileName: fileName, mediaType: mediaType)
                }
                .transition(.opacity)

            case .petSetup:
                PetSetupView { screen = .camera }
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: screen)
        .onChange(of: cameraViewModel.captureState) { _, newState in
            if case .captured(let fileName, let mediaType) = newState {
                screen = .celebration(fileName: fileName, mediaType: mediaType)
            }
        }
    }

    private var cameraScreen: some View {
        CameraView(viewModel: cameraViewModel, onPetSetup: { screen = .petSetup })
    }

    private func publishEntry(fileName: String, mediaType: MediaType) {
        let entry = JournalEntry(mediaType: mediaType, mediaFileName: fileName)
        modelContext.insert(entry)
        try? modelContext.save()

        // 重置回相机
        cameraViewModel.captureState = .idle
        screen = .camera
    }
}
