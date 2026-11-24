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
    private let notesKey = "lessonNoteOverrides"
    private var savedNotes: [String: String]
    private var overrides: [String: Bool]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        savedNotes = defaults.dictionary(forKey: notesKey) as? [String: String] ?? [:]
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
        if let key = item.occurrenceKey {
            item.completionOverride = overrides[key]
            if let note = savedNotes[key] {
                item.notes = note.isEmpty ? nil : note
            }
        }
        lessons.append(item)
    }
    
    func updateLesson(_ draft: Lesson) {
        guard let index = lessons.firstIndex(where: { $0.id == draft.id }) else { return }
        lessons[index].title = draft.title
        lessons[index].timeSlot = draft.timeSlot
        if lessons[index].notes != draft.notes, let key = lessons[index].occurrenceKey {
            // An empty value remembers that the user cleared the bundled note.
            savedNotes[key] = draft.notes ?? ""
            defaults.set(savedNotes, forKey: notesKey)
        }
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
