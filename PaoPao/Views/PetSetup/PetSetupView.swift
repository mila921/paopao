import SwiftUI
import SwiftData
import PhotosUI

struct PetSetupView: View {
    @Environment(\.modelContext) private var modelContext
    let onComplete: () -> Void

    @State private var step = 1
    @State private var direction: Edge = .trailing
    @State private var species: String? = nil
    @State private var customSpecies = ""
    @State private var traitTalk = 3
    @State private var traitTone = 3
    @State private var traitMode = 3
    @State private var traitFun = 3
    @State private var petName = ""
    @State private var avoid: [String] = []
    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil

    var body: some View {
        VStack(spacing: 0) {
            // 顶部进度指示
            HStack(spacing: 8) {
                ForEach(1...4, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Color(red: 0.31, green: 0.8, blue: 0.77) : Color.black.opacity(0.1))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // 返回按钮
            HStack {
                if step > 1 {
                    Button(action: goBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.black.opacity(0.6))
                    }
                }
                Spacer()
                Button(action: onComplete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black.opacity(0.4))
                        .padding(8)
                        .background(Circle().fill(.black.opacity(0.05)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .frame(height: 44)

            // 步骤内容
            Group {
                switch step {
                case 1:
                    SpeciesSelectionView(selected: $species, customSpecies: $customSpecies, avatarItem: $avatarItem, avatarImage: $avatarImage)
                case 2:
                    TraitSlidersView(talk: $traitTalk, tone: $traitTone, mode: $traitMode, fun: $traitFun)
                case 3:
                    NamingView(name: $petName, avoid: $avoid)
                default:
                    PreviewView(
                        species: species ?? "cat",
                        name: petName,
                        traits: (traitTalk, traitTone, traitMode, traitFun),
                        avatarImage: avatarImage,
                        onConfirm: savePet
                    )
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: direction),
                removal: .move(edge: direction == .trailing ? .leading : .trailing)
            ))
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: step)

            Spacer()

            // 底部按钮
            if step < 4 {
                Button(action: goNext) {
                    Text(step == 3 ? "生成我的宠物" : "下一步")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canProceed ? Color(red: 0.31, green: 0.8, blue: 0.77) : Color.black.opacity(0.1))
                        .clipShape(Capsule())
                }
                .disabled(!canProceed)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.97).ignoresSafeArea())
    }

    private var canProceed: Bool {
        switch step {
        case 1: return species != nil
        case 3: return !petName.isEmpty
        default: return true
        }
    }

    private func goNext() {
        direction = .trailing
        if step == 1, let sp = species {
            let defaults: (Int, Int, Int, Int) = switch sp {
            case "cat": (2, 2, 3, 3)
            case "dog": (4, 4, 4, 3)
            case "rabbit": (2, 4, 4, 2)
            case "fox": (3, 2, 2, 4)
            default: (3, 3, 3, 3)
            }
            traitTalk = defaults.0; traitTone = defaults.1; traitMode = defaults.2; traitFun = defaults.3
        }
        withAnimation { step += 1 }
    }

    private func goBack() {
        direction = .leading
        withAnimation { step -= 1 }
    }

    private func savePet() {
        var avatarFileName = ""
        if let image = avatarImage, let data = image.jpegData(compressionQuality: 0.8) {
            avatarFileName = "pet_avatar_\(UUID().uuidString).jpg"
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(avatarFileName)
            try? data.write(to: url)
        }

        let finalSpecies = customSpecies.isEmpty ? (species ?? "cat") : customSpecies
        let profile = PetProfile(
            name: petName,
            species: finalSpecies,
            traits: (traitTalk, traitTone, traitMode, traitFun),
            avoid: avoid,
            avatarFileName: avatarFileName
        )
        modelContext.insert(profile)
        try? modelContext.save()
        onComplete()
    }
}
