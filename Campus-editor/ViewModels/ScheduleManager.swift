import Foundation

protocol ScheduleManaging {
    var lessons: [Lesson] { get }
    func addObserver(_ observer: EventObserver)
    func addLesson(_ lesson: Lesson)
    func updateLesson(_ lesson: Lesson)
    func toggleCompletion(id: UUID)
    func checkTimeAndNotify(simulatedTime: String, dateKey: String) -> [String]
}

class ScheduleManager: EventSubject, ScheduleManaging {
    private(set) var lessons: [Lesson] = []
    
    // Масив підписників
    private var observers: [EventObserver] = []
    
    private let defaults: UserDefaults
    private let overridesKey = "lessonCompletionOverrides"
    private var overrides: [String: Bool]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        overrides = defaults.dictionary(forKey: overridesKey) as? [String: Bool] ?? [:]
    }

    func addObserver(_ observer: EventObserver) {
        observers.append(observer)
    }
    
    func notifyObservers(message: String) {
        for observer in observers {
            observer.update(message: message)
        }
    }
    
    func addLesson(_ lesson: Lesson) {
        var item = lesson
        if let key = item.occurrenceKey { item.completionOverride = overrides[key] }
        lessons.append(item)
    }
    
    func updateLesson(_ draft: Lesson) {
        guard let index = lessons.firstIndex(where: { $0.id == draft.id }) else { return }
        lessons[index].title = draft.title
        lessons[index].timeSlot = draft.timeSlot
        lessons[index].notes = draft.notes
    }

    func toggleCompletion(id: UUID) {
        guard let index = lessons.firstIndex(where: { $0.id == id }) else { return }
        let value = !lessons[index].completed(at: Date())
        lessons[index].completionOverride = value
        if let key = lessons[index].occurrenceKey {
            overrides[key] = value
            defaults.set(overrides, forKey: overridesKey)
        }
    }
    
    func checkTimeAndNotify(simulatedTime: String, dateKey: String) -> [String] {
        var messages: [String] = []
        for lesson in lessons where lesson.dateKey == dateKey {
            let message: String
            if lesson.timeSlot == simulatedTime {
                message = "Починається пара: \(lesson.title)"
            } else if lesson.reminderTime == simulatedTime {
                message = "Через 10 хвилин: \(lesson.title)"
            } else {
                continue
            }
            messages.append(message)
            notifyObservers(message: message + (lesson.meetingLink.map { " · \($0)" } ?? ""))
        }
        return messages
    }
}
