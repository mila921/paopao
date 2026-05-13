import SwiftData
import Foundation

enum MediaType: String, Codable {
    case photo, video
}

enum EmotionType: String, Codable, CaseIterable {
    case confetti, bouncingCat, sparkles
}

@Model
final class JournalEntry {
    var id: UUID
    var createdAt: Date
    var mediaType: MediaType
    var mediaFileName: String
    var aiComment: String
    var emotionType: EmotionType

    init(mediaType: MediaType, mediaFileName: String) {
        self.id = UUID()
        self.createdAt = Date()
        self.mediaType = mediaType
        self.mediaFileName = mediaFileName
        self.emotionType = EmotionType.allCases.randomElement() ?? .confetti
        self.aiComment = [
            "喵~ 今天的你看起来心情不错！",
            "铲屎官，这张照片我给满分！",
            "泡泡觉得你今天特别好看喵~",
            "喵呜，记录生活的你最棒了！",
            "这一刻值得被记住，喵！"
        ].randomElement()!
    }
}
