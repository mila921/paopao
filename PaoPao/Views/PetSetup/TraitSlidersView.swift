import SwiftUI

struct TraitSlidersView: View {
    @Binding var talk: Int
    @Binding var tone: Int
    @Binding var mode: Int
    @Binding var fun: Int

    var body: some View {
        VStack(spacing: 24) {
            Text("调整性格")
                .font(.system(size: 26, weight: .heavy, design: .serif))
                .foregroundStyle(.black.opacity(0.8))
                .padding(.top, 20)

            Text("滑动调节，塑造专属个性")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.black.opacity(0.4))

            VStack(spacing: 28) {
                traitSlider(label: "话少", rightLabel: "话多", value: $talk,
                           labels: ["只说重点", "话比较少", "中等", "爱唠叨", "超级话痨"])
                traitSlider(label: "腹黑", rightLabel: "温柔", value: $tone,
                           labels: ["腹黑毒舌", "有点毒", "中等", "比较温柔", "温柔治愈"])
                traitSlider(label: "理性", rightLabel: "感性", value: $mode,
                           labels: ["超级理性", "偏理性", "两者兼备", "偏感性", "超级感性"])
                traitSlider(label: "正经", rightLabel: "搞怪", value: $fun,
                           labels: ["一本正经", "偏正经", "中等", "有点搞怪", "超级搞怪"])
            }
            .padding(.horizontal, 24)
        }
    }

    private func traitSlider(label: String, rightLabel: String, value: Binding<Int>, labels: [String]) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.black.opacity(0.4))
                Spacer()
                Text(labels[value.wrappedValue - 1])
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.31, green: 0.8, blue: 0.77))
                Spacer()
                Text(rightLabel)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.black.opacity(0.4))
            }

            // 5档选择器
            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { i in
                    Button(action: { withAnimation(.spring(response: 0.25)) { value.wrappedValue = i } }) {
                        Circle()
                            .fill(i == value.wrappedValue ?
                                  Color(red: 0.31, green: 0.8, blue: 0.77) :
                                  Color.black.opacity(0.08))
                            .frame(width: i == value.wrappedValue ? 28 : 20,
                                   height: i == value.wrappedValue ? 28 : 20)
                    }
                    if i < 5 {
                        Rectangle()
                            .fill(Color.black.opacity(0.08))
                            .frame(height: 2)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
    }
}
