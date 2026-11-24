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
    
    var occurrenceKey: String?
    var completionOverride: Bool?
    var dateKey: String = ""
    var duration: Int = 0
    var details: String = ""

    var hasNote: Bool {
        !(notes ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var startMinutes: Int? {
        let parts = timeSlot.split(separator: ":")
        guard parts.count == 2, let hour = Int(parts[0]), let minute = Int(parts[1]),
              (0..<24).contains(hour), (0..<60).contains(minute) else { return nil }
        return hour * 60 + minute
    }

    static func clockTime(_ minutes: Int) -> String {
        let normalized = (minutes % 1440 + 1440) % 1440
        return String(format: "%02d:%02d", normalized / 60, normalized % 60)
    }

    var reminderTime: String? { startMinutes.map { Self.clockTime($0 - 10) } }

    var timeRange: String {
        guard let start = startMinutes, duration > 0 else { return timeSlot }
        return "\(timeSlot) – \(Self.clockTime(start + duration))"
    }

    var endDate: Date? {
        guard let date = Timetable.dateFormat.date(from: dateKey), let start = startMinutes,
              duration > 0, let begins = Timetable.calendar.date(
                bySettingHour: start / 60, minute: start % 60, second: 0, of: date
              ) else { return nil }
        return begins.addingTimeInterval(TimeInterval(duration * 60))
    }

    func completed(at now: Date) -> Bool {
        completionOverride ?? (endDate.map { $0 <= now } ?? false)
    }
}
