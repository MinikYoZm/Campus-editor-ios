import Foundation

class ScheduleManager: EventSubject {
    var lessons: [Lesson] = []
    
    // Масив підписників
    private var observers: [EventObserver] = []
    
    func addObserver(_ observer: EventObserver) {
        observers.append(observer)
    }
    
    func notifyObservers(message: String) {
        for observer in observers {
            observer.update(message: message)
        }
    }
    
    func addLesson(_ lesson: Lesson) {
        lessons.append(lesson)
    }
    
    func completeQuestInSchedule(id: UUID) {
        if let index = lessons.firstIndex(where: { $0.id == id }) {
            lessons[index].completeQuest()
        }
    }
    
    func checkTimeAndNotify(simulatedTime: String) {
        print("\n--- Перевірка часу: \(simulatedTime) ---")
        for lesson in lessons {
            if lesson.timeSlot == simulatedTime {
                notifyObservers(message: "Квест '\(lesson.title)' розпочався! Посилання: \(lesson.meetingLink ?? "відсутнє")")
            }
        }
    }
}
