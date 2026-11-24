import Foundation
import SwiftUI

class GamificationFacade: ObservableObject {
    // Властивість, яку бачить і малює UI
    @Published private(set) var displayLessons: [Lesson] = []
    
    private let scheduleManager: ScheduleManaging

    init(scheduleManager: ScheduleManaging, observer: EventObserver, lessons: [Lesson] = Timetable.load()) {
        self.scheduleManager = scheduleManager
        scheduleManager.addObserver(observer)

        lessons.forEach(scheduleManager.addLesson)
        updateUI()
    }

    func lessons(on date: Date) -> [Lesson] {
        let key = Timetable.dateFormat.string(from: date)
        return displayLessons.filter { $0.dateKey == key }.sorted { $0.timeSlot < $1.timeSlot }
    }

    func updateLesson(_ lesson: Lesson) {
        scheduleManager.updateLesson(lesson)
        updateUI()
    }

    func toggleCompletion(id: UUID) {
        scheduleManager.toggleCompletion(id: id)
        updateUI()
    }
    
    var testTimes: [String] {
        let starts = displayLessons.map(\.timeSlot)
        let reminders = displayLessons.compactMap(\.reminderTime)
        return Set(starts + reminders).sorted()
    }

    @discardableResult
    func simulateTimeCheck(time: String, on date: Date) -> [String] {
        scheduleManager.checkTimeAndNotify(simulatedTime: time, dateKey: Timetable.dateFormat.string(from: date))
    }
    
    func refreshElapsedLessons() {
        let now = Date()
        if displayLessons.contains(where: { $0.isCompleted != $0.completed(at: now) }) {
            updateUI()
        }
    }

    private func updateUI() {
        // Оновлюємо @Published масив, щоб екран перемалювався
        let now = Date()
        displayLessons = scheduleManager.lessons.map { lesson in
            var displayed = lesson
            displayed.isCompleted = lesson.completed(at: now)
            return displayed
        }
    }
}
