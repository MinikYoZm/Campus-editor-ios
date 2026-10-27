
import Foundation

// Визначає базові вимоги для будь-якого завдання в нашому застосунку
protocol QuestItem {
    var title: String { get }
    var isCompleted: Bool { get set }
    mutating func completeQuest()
}

// (enum): Дні тижня
enum WeekDay: String {
    case monday = "Понеділок"
    case tuesday = "Вівторок"
    case wednesday = "Середа"
    case thursday = "Четвер"
    case friday = "П'ятниця"
    case saturday = "Субота"
}

// (struct): Описує конкретну пару (квест), має семантику значення
struct Lesson: QuestItem {
    let title: String  // Константа - назва предмета не змінюється
    let lecturer: String
    let weekday: WeekDay
    let timeSlot: String
    
    // посилання та нотатки можуть бути, а можуть і не бути
    var meetingLink: String?
    var notes: String?
    
    // (var), бо статус виконання може змінюватися
    var isCompleted: Bool = false
    
    // Метод, який змінює стан структури (mutating)
    mutating func completeQuest() {
        self.isCompleted = true
        print("Квест '\(title)' успішно виконано!")
    }
}

// (class): Менеджер розкладу, має семантику посилання
class ScheduleManager {
    // Колекція для зберігання всіх пар
    private var lessons: [Lesson]
    
    // Ініціалізація класу
    init() {
        self.lessons = []
    }
    
    // Метод додавання нової пари
    func addLesson(_ lesson: Lesson) {
        lessons.append(lesson)
        print("Додано нову пару: \(lesson.title) на \(lesson.weekday.rawValue)")
    }
    // Метод для позначення квесту як виконаного безпосередньо в колекції
        func completeQuestInSchedule(title: String) {
            // Шукаємо індекс пари за її назвою
            if let index = lessons.firstIndex(where: { $0.title == title }) {
                lessons[index].completeQuest() // Змінюємо статус (mutating) прямо в масиві
            } else {
                print("Квест '\(title)' не знайдено у розкладі.")
            }
        }    // Метод фільтрації пар за днем тижня + використання умовної конструкції та циклу
    func showSchedule(for day: WeekDay) {
        print("\n--- Розклад на \(day.rawValue) ---")
        
        let filteredLessons = lessons.filter { $0.weekday == day }
        
        if filteredLessons.isEmpty {
            print("На цей день пар немає! Можна відпочивати.")
        } else {
            // Обробка елементів колекції
            for lesson in filteredLessons {
                let status = lesson.isCompleted ? "[X]" : "[ ]"
                print("\(status) \(lesson.timeSlot) - \(lesson.title) (\(lesson.lecturer))")
                
                // Безпечне розгортання Optional (Optional Binding)
                if let link = lesson.meetingLink {
                    print("  Посилання: \(link)")
                } else {
                    print("  Посилання відсутнє")
                }
            }
        }
    }
}

//  Реалізація сценарію (можна додати у ContentView.swift або у функцію main) ===
func runTimeFlowScenario() {
    // Створення екземпляра класу
    let mySchedule = ScheduleManager()
    
    // Створення сутностей (пар)
    let proLesson = Lesson(title: "PRO", lecturer: "Homal D.R.", weekday: .monday, timeSlot: "08:30", meetingLink: "https://zoom.us/pro", notes: "Підготуватися до тесту")
    let iosLesson = Lesson(title: "IOS", lecturer: "Jenkins P.D.", weekday: .monday, timeSlot: "10:25", meetingLink: nil, notes: nil)
    
    // Додавання до колекції
    mySchedule.addLesson(proLesson)
    mySchedule.addLesson(iosLesson)
    
    // Зміна стану сутності
    mySchedule.completeQuestInSchedule(title: "PRO")
    
    // Виведення результату
    mySchedule.showSchedule(for: .monday)
    mySchedule.showSchedule(for: .tuesday)
}
