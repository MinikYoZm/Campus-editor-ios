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

    func completeQuest(id: UUID) {
        scheduleManager.completeQuestInSchedule(id: id)
        updateUI()
    }
    
    func simulateTimeCheck(time: String, on date: Date) {
        scheduleManager.checkTimeAndNotify(simulatedTime: time, dateKey: Timetable.dateFormat.string(from: date))
    }
    
    private func updateUI() {
        // Оновлюємо @Published масив, щоб екран перемалювався
        displayLessons = scheduleManager.lessons
    }
}
