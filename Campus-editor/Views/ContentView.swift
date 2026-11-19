import SwiftUI

struct ContentView: View {
    @ObservedObject var gamificationSystem: GamificationFacade
    @StateObject private var router = ScheduleRouter()

    var body: some View {
        if #available(macOS 13, iOS 16, *) {
            NavigationStack(path: $router.path) {
                schedule
                    .navigationDestination(for: UUID.self) { id in
                        details(for: id)
                    }
            }
        } else {
            // На macOS 12 NavigationStack ще недоступний.
            NavigationView {
                schedule
                if let id = router.path.last {
                    details(for: id)
                }
            }
        }
    }

    private var schedule: some View {
        List {
            Section("Заняття") {
                ForEach(gamificationSystem.displayLessons) { lesson in
                    HStack {
                        Button {
                            router.showDetails(for: lesson.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title).font(.headline)
                                Text("\(lesson.timeSlot) · \(lesson.weekday.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(lesson.title)
                        .accessibilityIdentifier("open-\(lesson.title)")

                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                                gamificationSystem.completeQuest(id: lesson.id)
                            }
                        } label: {
                            ZStack {
                                if lesson.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .transition(.scale(scale: 1.5).combined(with: .opacity))
                                } else {
                                    Image(systemName: "circle").foregroundColor(.secondary)
                                }
                            }
                            .font(.title2)
                            .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(lesson.isCompleted ? "Виконано" : "Позначити виконаним")
                    }
                }
            }

            Section("Перевірка часу") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 95))]) {
                    ForEach(["08:20", "08:30", "10:15", "10:25", "11:55", "12:15"], id: \.self) { time in
                        Button(time) { gamificationSystem.simulateTimeCheck(time: time) }
                            .buttonStyle(.bordered)
                    }
                }
            }
        }
        .navigationTitle("TimeFlow Квести")
    }

    private func details(for id: UUID) -> some View {
        Group {
            if let lesson = gamificationSystem.displayLessons.first(where: { $0.id == id }) {
                LessonDetailView(lesson: lesson) { router.edit(lesson) }
            }
        }
        .sheet(item: $router.editingLesson) { lesson in
            LessonEditorView(lesson: lesson, onSave: { draft in
                gamificationSystem.updateLesson(draft)
                router.closeEditor()
            }, onCancel: router.closeEditor)
        }
    }
}
