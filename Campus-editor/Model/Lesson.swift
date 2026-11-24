import Foundation

enum WeekDay: String, CaseIterable {
    case monday = "Понеділок"
    case tuesday = "Вівторок"
    case wednesday = "Середа"
    case thursday = "Четвер"
    case friday = "П'ятниця"
    case saturday = "Субота"
    case sunday = "Неділя"
}

struct Lesson: Identifiable {
    let id = UUID()
    var title: String
    var weekday: WeekDay
    var timeSlot: String
    var meetingLink: String?
    var notes: String?
    var isCompleted: Bool = false
    
    var dateKey: String = ""
    var duration: Int = 0
    var details: String = ""

    var timeRange: String {
        let parts = timeSlot.split(separator: ":").compactMap { Int($0) }
        guard duration > 0, parts.count == 2 else { return timeSlot }
        let end = (parts[0] * 60 + parts[1] + duration) % 1440
        return String(format: "%@ – %02d:%02d", timeSlot, end / 60, end % 60)
    }

    mutating func completeQuest() {
        self.isCompleted = true
    }
}
