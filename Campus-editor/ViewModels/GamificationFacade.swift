import Foundation
import SwiftUI

class GamificationFacade: ObservableObject {
    // Властивість, яку бачить і малює UI
    @Published var displayLessons: [Lesson] = []
    
    private let scheduleManager = ScheduleManager()
    private let pushService = PushNotificationService()
    
    init() {
        // Фасад налаштовує підписку патерна Observer
        scheduleManager.addObserver(pushService)
        
        addRegularQuest(title: "PRO", time: "08:30", link: "https://zoom.us/pro")
        addRegularQuest(title: "IOS", time: "10:25", link: "https://meet/ios")
        addBossQuest(title: "Test AK", time: "12:15", notes: "Взяти конспект")
    }
    
    // Методи Фасаду, що приховують складність від View
    func addRegularQuest(title: String, time: String, link: String? = nil, notes: String? = nil) {
        let quest = LessonBuilder()
            .setTitle(" " + title)
            .setTime(day: .monday, time: time)
            .setLink(link ?? "")
            .setNotes(notes ?? "")
            .build()
        
        scheduleManager.addLesson(quest)
        updateUI()
    }
    
    func addBossQuest(title: String, time: String, link: String? = nil, notes: String? = nil) {
        let boss = LessonBuilder()
            .setTitle(" БОС: " + title)
            .setTime(day: .monday, time: time)
            .setLink(link ?? "")
            .setNotes(notes ?? "")
            .build()
        
        scheduleManager.addLesson(boss)
        updateUI()
    }
    
    func completeQuest(id: UUID) {
        scheduleManager.completeQuestInSchedule(id: id)
        updateUI()
    }
    
    func simulateTimeCheck(time: String) {
        scheduleManager.checkTimeAndNotify(simulatedTime: time)
    }
    
    private func updateUI() {
        // Оновлюємо @Published масив, щоб екран перемалювався
        displayLessons = scheduleManager.lessons
    }
}
