import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    let onEdit: () -> Void

    var body: some View {
        List {
            Section("Заняття") {
                Text(lesson.title).font(.headline)
                Text("\(lesson.weekday.rawValue), \(lesson.timeRange)")
                Text(lesson.details).foregroundColor(.secondary)
                Label(lesson.isCompleted ? "Виконано" : "Заплановано",
                      systemImage: lesson.isCompleted ? "checkmark.circle.fill" : "calendar")
            }
            if let link = lesson.meetingLink, !link.isEmpty {
                Section("Посилання") { Text(link).textSelection(.enabled) }
            }
            if let notes = lesson.notes, !notes.isEmpty {
                Section("Нотатки") { Text(notes) }
            }
        }
        .navigationTitle("Деталі заняття")
        .toolbar {
            Button("Редагувати", action: onEdit)
        }
    }
}
