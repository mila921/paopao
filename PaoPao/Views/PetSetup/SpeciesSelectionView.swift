import SwiftUI

struct SpeciesSelectionView: View {
    @Binding var selected: String?
    @Binding var customSpecies: String

    private let options: [(species: String, emoji: String, name: String, desc: String)] = [
        ("cat", "🐱", "猫咪", "慵懒 · 腹黑 · 突然贴贴"),
        ("dog", "🐶", "狗狗", "热情 · 治愈 · 永远支持你"),
        ("rabbit", "🐰", "兔子", "软萌 · 话少 · 但很懂你"),
        ("fox", "🦊", "小狐狸", "聪明 · 毒舌 · 偶尔撒娇")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("选择你的宠物")
                    .font(.system(size: 26, weight: .heavy, design: .serif))
                    .foregroundStyle(.black.opacity(0.8))
                    .padding(.top, 20)

                Text("它会用独特的方式陪你记录生活")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.black.opacity(0.4))

                // 预设宠物
                VStack(spacing: 12) {
                    ForEach(options, id: \.species) { option in
                        Button(action: { selected = option.species; customSpecies = "" }) {
                            HStack(spacing: 16) {
                                Text(option.emoji).font(.system(size: 40))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(option.name)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black.opacity(0.8))
                                    Text(option.desc)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(.black.opacity(0.4))
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                selected == option.species && customSpecies.isEmpty ?
                                                    Color(red: 0.31, green: 0.8, blue: 0.77) : Color.clear,
                                                lineWidth: 2.5
                                            )
                                    )
                            )
                        }
                        .scaleEffect(selected == option.species && customSpecies.isEmpty ? 1.02 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
                    }
                }
                .padding(.horizontal, 24)

                // 自定义宠物
                VStack(alignment: .leading, spacing: 8) {
                    Text("或者，自定义你的宠物")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.black.opacity(0.5))

                    TextField("输入宠物类型，比如：仓鼠、鹦鹉...", text: $customSpecies)
                        .font(.system(size: 15, design: .rounded))
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    !customSpecies.isEmpty ? Color(red: 0.31, green: 0.8, blue: 0.77) : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .onChange(of: customSpecies) { _, newValue in
                            if !newValue.isEmpty { selected = "custom" }
                        }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 20)
            }
        }
    }
}
