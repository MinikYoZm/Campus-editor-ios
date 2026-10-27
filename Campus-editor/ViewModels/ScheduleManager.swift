import Foundation
import SwiftUI // Потрібно для ObservableObject

class ScheduleManager: ObservableObject {
    // @Published автоматично сповіщає View про зміни
    @Published var lessons: [Lesson] = []
    
    init() {

        addLesson(Lesson(title: "PRO", lecturer: "Homal D.R.", weekday: .monday, timeSlot: "08:30"))
        addLesson(Lesson(title: "IOS", lecturer: "Jenkins P.D.", weekday: .monday, timeSlot: "10:25"))
    }
    
    func addLesson(_ lesson: Lesson) {
        lessons.append(lesson)
    }
    
    // Змінюємо статус квесту за його унікальним ID
    func completeQuestInSchedule(id: UUID) {
        if let index = lessons.firstIndex(where: { $0.id == id }) {
            lessons[index].completeQuest()
        }
    }
}
