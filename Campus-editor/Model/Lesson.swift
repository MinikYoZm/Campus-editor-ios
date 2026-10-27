import Foundation

enum WeekDay: String {
    case monday = "Понеділок"
    case tuesday = "Вівторок"
    case wednesday = "Середа"
    case thursday = "Четвер"
    case friday = "П'ятниця"
    case saturday = "Субота"
}

struct Lesson: Identifiable {
    let id = UUID()
    var title: String
    var weekday: WeekDay
    var timeSlot: String
    var meetingLink: String?
    var notes: String?
    var isCompleted: Bool = false
    
    mutating func completeQuest() {
        self.isCompleted = true
    }
}
