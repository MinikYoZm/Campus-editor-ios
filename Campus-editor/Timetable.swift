import Foundation

enum Timetable {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv") ?? TimeZone(identifier: "Europe/Kiev")!
        return calendar
    }()

    static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func week(containing date: Date) -> [Date] {
        guard let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private struct Entry: Decodable {
        let date: String
        let start: String
        let duration: Int
        let title: String
        let details: String
    }

    static func load() -> [Lesson] {
        do {
            guard let url = Bundle.main.url(forResource: "Timetable", withExtension: "json") else {
                throw CocoaError(.fileNoSuchFile)
            }
            let entries = try JSONDecoder().decode([Entry].self, from: Data(contentsOf: url))
            return try entries.map { entry in
                guard let date = dateFormat.date(from: entry.date) else { throw CocoaError(.fileReadCorruptFile) }
                let weekday = WeekDay.allCases[(calendar.component(.weekday, from: date) + 5) % 7]
                var lesson = LessonBuilder()
                    .setTitle(entry.title)
                    .setTime(day: weekday, time: entry.start)
                    .build()
                lesson.dateKey = entry.date
                lesson.duration = entry.duration
                lesson.details = entry.details
                return lesson
            }
        } catch {
            assertionFailure("Помилка читання розкладу: \(error)")
            return []
        }
    }
}
