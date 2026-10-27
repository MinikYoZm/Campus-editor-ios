import Foundation

protocol QuestItem {
    var title: String { get }
    var isCompleted: Bool { get set }
    mutating func completeQuest()
}

enum WeekDay: String {
    case monday = "Понеділок"
    case tuesday = "Вівторок"
    case wednesday = "Середа"
    case thursday = "Четвер"
    case friday = "П'ятниця"
    case saturday = "Субота"
}

struct Lesson: QuestItem, Identifiable {
    let id = UUID() // Унікальний ідентифікатор для списків SwiftUI
    let title: String
    let lecturer: String
    let weekday: WeekDay
    let timeSlot: String
    var meetingLink: String?
    var notes: String?
    var isCompleted: Bool = false
    
    mutating func completeQuest() {
        self.isCompleted = true
    }
}
