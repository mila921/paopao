import SwiftUI
import SwiftData

enum AppScreen: Equatable {
    case camera
    case celebration(fileName: String, mediaType: MediaType)
    case petSetup
    case petProfile
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [PetProfile]
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

            case .petProfile:
                if let pet = pets.first {
                    PetProfileView(pet: pet, onClose: { screen = .camera })
                        .transition(.move(edge: .bottom))
                }
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
        CameraView(viewModel: cameraViewModel, petAvatarFileName: pets.first?.avatarFileName ?? "", onPetSetup: {
            if pets.isEmpty {
                screen = .petSetup
            } else {
                screen = .petProfile
            }
        })
    }

    private func publishEntry(fileName: String, mediaType: MediaType) {
        let entry = JournalEntry(mediaType: mediaType, mediaFileName: fileName)
        modelContext.insert(entry)
        try? modelContext.save()

        cameraViewModel.captureState = .idle
        screen = .camera
    }
}
