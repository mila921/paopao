import SwiftData
import Foundation

@Model
final class PetProfile {
    var id: UUID
    var name: String
    var species: String
    var emoji: String
    var traitTalk: Int
    var traitTone: Int
    var traitMode: Int
    var traitFun: Int
    var avoid: [String]
    var systemPrompt: String
    var createdAt: Date
    var updatedAt: Date

    init(name: String, species: String, traits: (talk: Int, tone: Int, mode: Int, fun: Int), avoid: [String]) {
        self.id = UUID()
        self.name = name
        self.species = species
        let emojiMap = ["cat": "🐱", "dog": "🐶", "rabbit": "🐰", "fox": "🦊"]
        self.emoji = emojiMap[species] ?? "🐾"
        self.traitTalk = traits.talk
        self.traitTone = traits.tone
        self.traitMode = traits.mode
        self.traitFun = traits.fun
        self.avoid = avoid
        self.createdAt = Date()
        self.updatedAt = Date()
        self.systemPrompt = PetProfile.generatePrompt(
            name: name, species: species, traits: traits, avoid: avoid
        )
    }

    static func generatePrompt(name: String, species: String, traits: (talk: Int, tone: Int, mode: Int, fun: Int), avoid: [String]) -> String {
        let speciesName: String = switch species {
        case "cat": "猫"
        case "dog": "狗"
        case "rabbit": "兔子"
        case "fox": "小狐狸"
        default: species
        }
        let talkLabels = ["只说重点", "话比较少", "中等", "爱唠叨", "超级话痨"]
        let toneLabels = ["腹黑毒舌", "有点毒", "中等", "比较温柔", "温柔治愈"]
        let modeLabels = ["超级理性", "偏理性", "两者兼备", "偏感性", "超级感性"]
        let funLabels = ["一本正经", "偏正经", "中等", "有点搞怪", "超级搞怪"]

        var prompt = "你是\(name)，一只\(toneLabels[traits.tone - 1])的\(speciesName)。\n"
        prompt += "说话风格：\(talkLabels[traits.talk - 1])，\(modeLabels[traits.mode - 1])，\(funLabels[traits.fun - 1])。\n"
        prompt += "你的职责是评论主人拍下的日常小事，语气自然，像真实宠物说话。\n"
        prompt += "每次回复控制在 2-3 句话以内。\n"

        switch species {
        case "cat":
            prompt += "【猫咪规则】不能表现得太在乎，但偶尔可以漏出关心。\n"
        case "dog":
            prompt += "【狗狗规则】热情回应，可以有点激动。\n"
        case "rabbit":
            prompt += "【兔子规则】话少但精准，偶尔冒出一句让人暖心的话。\n"
        case "fox":
            prompt += "【小狐狸规则】聪明毒舌，但偶尔会撒娇示弱。\n"
        default:
            prompt += "【\(species)规则】用符合\(species)特征的方式说话。\n"
        }

        if !avoid.isEmpty {
            let avoidMap = [
                "marriage_pressure": "催婚催育", "work_stress": "工作压力",
                "appearance": "身材外貌", "money": "钱的话题",
                "relationship": "感情状态", "academic": "学业成绩",
                "family": "家庭关系", "health_anxiety": "健康焦虑"
            ]
            let labels = avoid.compactMap { avoidMap[$0] }.joined(separator: "、")
            prompt += "绝对不主动提及：\(labels)。即使内容涉及这些话题，也只评论积极面，不深入追问。"
        }
        return prompt
    }
}
