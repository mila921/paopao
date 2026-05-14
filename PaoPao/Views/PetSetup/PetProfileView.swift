import SwiftUI
import SwiftData

struct PetProfileView: View {
    let pet: PetProfile
    let onClose: () -> Void

    private var traitTags: [String] {
        let talkLabels = ["只说重点", "话比较少", "中等", "爱唠叨", "超级话痨"]
        let toneLabels = ["腹黑毒舌", "有点毒", "中等", "比较温柔", "温柔治愈"]
        let modeLabels = ["超级理性", "偏理性", "两者兼备", "偏感性", "超级感性"]
        let funLabels = ["一本正经", "偏正经", "中等", "有点搞怪", "超级搞怪"]
        return [
            talkLabels[pet.traitTalk - 1],
            toneLabels[pet.traitTone - 1],
            modeLabels[pet.traitMode - 1],
            funLabels[pet.traitFun - 1]
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部关闭按钮
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black.opacity(0.4))
                        .padding(8)
                        .background(Circle().fill(.black.opacity(0.05)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 头像
                    if let img = loadAvatar() {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 4))
                            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                    } else {
                        Text(pet.emoji).font(.system(size: 60))
                    }

                    // 名字和物种
                    VStack(spacing: 4) {
                        Text(pet.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.black.opacity(0.8))
                        Text(pet.species)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.black.opacity(0.4))
                    }

                    // 性格标签
                    VStack(alignment: .leading, spacing: 12) {
                        Text("性格档案")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundStyle(.black.opacity(0.7))

                        FlowLayout(spacing: 10) {
                            ForEach(traitTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(Color(red: 0.31, green: 0.8, blue: 0.77))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color(red: 0.31, green: 0.8, blue: 0.77).opacity(0.12)))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.white))
                    .padding(.horizontal, 24)

                    // 创建时间
                    Text("陪伴你 \(daysSinceCreation) 天了")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.black.opacity(0.4))
                }
                .padding(.top, 12)
            }
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.97).ignoresSafeArea())
    }

    private var daysSinceCreation: Int {
        max(1, Calendar.current.dateComponents([.day], from: pet.createdAt, to: Date()).day ?? 1)
    }

    private func loadAvatar() -> UIImage? {
        guard !pet.avatarFileName.isEmpty else { return nil }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(pet.avatarFileName)
        return UIImage(contentsOfFile: url.path)
    }
}
