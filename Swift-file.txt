import Foundation

// 1. Enum: Дні тижня
enum DayOfWeek: String {
    case monday = "Понеділок"
    case tuesday = "Вівторок"
    case wednesday = "Середа"
    case thursday = "Четвер"
    case friday = "П'ятниця"
}

// 2. Protocol: Вимоги до будь-якого елемента розкладу
protocol ScheduleItem {
    var id: UUID { get }
    var title: String { get }
    func displayInfo()
}

// 3. Struct (Value Type): Пара
struct Lesson: ScheduleItem {
    let id: UUID = UUID() // let - унікальний ідентифікатор не змінюється
    var title: String
    var teacher: String
    var day: DayOfWeek
    var timeSlot: String
    var meetingLink: String? // Optional - посилання може бути відсутнім
    var notes: String?       // Optional - нотатки теж не завжди є
    
    // Метод, який вимагає протокол
    func displayInfo() {
        print("🕒 \(timeSlot) | \(title) (\(teacher))")
        
        // Безпечне розгортання Optional (if let)
        if let link = meetingLink {
            print("   🔗 Посилання: \(link)")
        } else {
            print("   🏢 Офлайн / Без посилання")
        }
        
        if let note = notes {
            print("   📝 Нотатка: \(note)")
        }
    }
}

// 4. Class (Reference Type): Менеджер розкладу
class Schedule {
    // Колекція (Масив) для збереження пар
    private var lessons: [Lesson] = []
    
    // Додавання нової пари
    func addLesson(_ lesson: Lesson) {
        lessons.append(lesson)
        print("✅ Успішно додано пару: \(lesson.title) на \(lesson.day.rawValue)")
    }
    
    // Фільтрація занять за певним днем тижня
    func showLessons(for day: DayOfWeek) {
        print("\n📅 РОЗКЛАД НА: \(day.rawValue.uppercased())")
        
        // Використовуємо фільтр для колекції
        let filteredLessons = lessons.filter { $0.day == day }
        
        // Умовна конструкція: перевірка чи є пари
        guard !filteredLessons.isEmpty else {
            print("🎉 На цей день пар немає! Можна відпочивати.")
            return
        }
        
        // Обробка елементів колекції циклом
        for lesson in filteredLessons {
            lesson.displayInfo()
            print("---")
        }
    }
    
    // 5. Метод для запуску сценарію в консолі
    func runScenario() {
        print("=== ЗАПУСК CAMPUS-EDITOR ===")
        
        // Створення сутностей
        let mathLesson = Lesson(title: "Вища математика", teacher: "Іваненко І.І.", day: .monday, timeSlot: "08:30 - 10:05", meetingLink: "https://zoom.us/math", notes: "Підготувати домашнє завдання")
        
        let swiftLesson = Lesson(title: "Розробка iOS", teacher: "Петренко П.П.", day: .monday, timeSlot: "10:25 - 12:00", meetingLink: "https://meet.google.com/ios", notes: nil)
        
        let peLesson = Lesson(title: "Фізичне виховання", teacher: "Сидоренко С.С.", day: .tuesday, timeSlot: "08:30 - 10:05", meetingLink: nil, notes: "Взяти спортивну форму")
        
        // Додавання в колекцію
        addLesson(mathLesson)
        addLesson(swiftLesson)
        addLesson(peLesson)
        
        // Виведення розкладу
        showLessons(for: .monday)
        showLessons(for: .tuesday)
        showLessons(for: .wednesday) // День без пар
    }
}
