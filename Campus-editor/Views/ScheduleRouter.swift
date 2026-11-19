import SwiftUI

final class ScheduleRouter: ObservableObject {
    @Published var path: [UUID] = []
    @Published var editingLesson: Lesson?

    func showDetails(for id: UUID) {
        path = [id]
    }

    func edit(_ lesson: Lesson) {
        editingLesson = lesson
    }

    func closeEditor() {
        editingLesson = nil
    }
}
