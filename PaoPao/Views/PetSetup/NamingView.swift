import SwiftUI

struct NamingView: View {
    @Binding var name: String
    @Binding var avoid: [String]
    @Binding var quirks: String

    private let avoidOptions: [(key: String, label: String)] = [
        ("marriage_pressure", "催婚催育"),
        ("work_stress", "工作压力"),
        ("appearance", "身材外貌"),
        ("money", "钱的话题"),
        ("relationship", "感情状态"),
        ("academic", "学业成绩"),
        ("family", "家庭关系"),
        ("health_anxiety", "健康焦虑")
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("给它取个名字")
                .font(.system(size: 26, weight: .heavy, design: .serif))
                .foregroundStyle(.black.opacity(0.8))
                .padding(.top, 20)

            // 名字输入
            TextField("比如：泡泡、豆豆、阿橘...", text: $name)
                .font(.system(size: 17, design: .rounded))
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                .padding(.horizontal, 24)
                .onChange(of: name) { _, newValue in
                    if newValue.count > 6 { name = String(newValue.prefix(6)) }
                }

            // 小癖好和性格特征
            VStack(alignment: .leading, spacing: 8) {
                Text("它有什么小癖好？")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.5))

                TextField("比如：喜欢蹭人腿、爱吃零食、一到晚上就疯跑...", text: $quirks, axis: .vertical)
                    .font(.system(size: 15, design: .rounded))
                    .lineLimit(3...5)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(.white))
            }
            .padding(.horizontal, 24)

            // 禁区标签
            VStack(alignment: .leading, spacing: 12) {
                Text("它不会主动聊这些话题")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.black.opacity(0.5))
                    .padding(.horizontal, 24)

                FlowLayout(spacing: 10) {
                    ForEach(avoidOptions, id: \.key) { option in
                        Button(action: { toggleAvoid(option.key) }) {
                            Text(option.label)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(avoid.contains(option.key) ? .white : .black.opacity(0.6))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(
                                        avoid.contains(option.key) ?
                                            Color(red: 0.31, green: 0.8, blue: 0.77) :
                                            Color.white
                                    )
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func toggleAvoid(_ key: String) {
        if let idx = avoid.firstIndex(of: key) {
            avoid.remove(at: idx)
        } else {
            avoid.append(key)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
