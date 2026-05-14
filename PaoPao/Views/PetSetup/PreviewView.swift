import SwiftUI

struct PreviewView: View {
    let species: String
    let name: String
    let traits: (Int, Int, Int, Int)
    let avatarImage: UIImage?
    let onConfirm: () -> Void

    @State private var progress: CGFloat = 0
    @State private var visibleComments: Int = 0
    @State private var showButton = false

    private var emoji: String {
        ["cat": "🐱", "dog": "🐶", "rabbit": "🐰", "fox": "🦊"][species] ?? "🐾"
    }
    private var speciesName: String {
        ["cat": "猫咪", "dog": "狗狗", "rabbit": "兔子", "fox": "小狐狸"][species] ?? species
    }

    private var traitTags: [String] {
        let talkLabels = ["只说重点", "话比较少", "中等", "爱唠叨", "超级话痨"]
        let modeLabels = ["超级理性", "偏理性", "两者兼备", "偏感性", "超级感性"]
        let funLabels = ["一本正经", "偏正经", "中等", "有点搞怪", "超级搞怪"]
        return [talkLabels[traits.0 - 1], modeLabels[traits.2 - 1], funLabels[traits.3 - 1]]
    }

    private var sampleComments: [String] {
        switch species {
        case "cat":
            return ["被夸了啊。本猫勉强给你点个头。",
                    "哦，又出门了。记得带猫粮回来。",
                    "这张照片…本猫给7分吧，多的是情面。"]
        case "dog":
            return ["被夸了！！你上次也被夸过对不对！！汪！",
                    "出门啦！！好开心！！我也想去！！",
                    "这张照片超好看！！你最棒了！！汪汪！"]
        case "rabbit":
            return ["嗯…挺好的。", "今天也辛苦了呢。", "…悄悄说，你今天很好看。"]
        case "fox":
            return ["就这？开玩笑的啦~其实还不错。",
                    "本狐看穿了你在偷偷开心哦~",
                    "哼，算你有点品味吧。"]
        default:
            return ["今天也很棒呢！", "记录下来了，继续加油~", "这个瞬间值得留住！"]
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("你的专属宠物")
                .font(.system(size: 26, weight: .heavy, design: .serif))
                .foregroundStyle(.black.opacity(0.8))
                .padding(.top, 20)

            // 宠物卡片
            VStack(spacing: 12) {
                // 宠物头像
                if let img = avatarImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                } else {
                    Text(emoji).font(.system(size: 60))
                }
                Text(name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.8))
                Text(speciesName)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.black.opacity(0.4))

                // 性格标签
                HStack(spacing: 8) {
                    ForEach(traitTags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(Color(red: 0.31, green: 0.8, blue: 0.77))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color(red: 0.31, green: 0.8, blue: 0.77).opacity(0.12)))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 24).fill(.white))
            .padding(.horizontal, 24)

            // 进度条
            VStack(spacing: 8) {
                GeometryReader { geo in
                    Capsule()
                        .fill(Color.black.opacity(0.06))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Color(red: 0.31, green: 0.8, blue: 0.77))
                                .frame(width: geo.size.width * progress)
                        }
                }
                .frame(height: 6)

                Text(progress < 1 ? "正在生成性格档案..." : "生成完成！")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.black.opacity(0.4))
            }
            .padding(.horizontal, 24)

            // 示例评论
            VStack(spacing: 12) {
                ForEach(0..<visibleComments, id: \.self) { i in
                    HStack(alignment: .top, spacing: 10) {
                        if let img = avatarImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        } else {
                            Text(emoji).font(.system(size: 20))
                        }
                        Text(sampleComments[i])
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.black.opacity(0.7))
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 14).fill(.white))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // 确认按钮
            if showButton {
                Button(action: onConfirm) {
                    Text("开始用 \(name) 陪我记录")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 1.0, green: 0.9, blue: 0.43))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5)) { progress = 1.0 }
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7 + Double(i) * 0.5) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) { visibleComments = i + 1 }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) { showButton = true }
            }
        }
    }
}
