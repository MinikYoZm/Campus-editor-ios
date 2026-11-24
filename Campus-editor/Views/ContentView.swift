import SwiftUI

struct ContentView: View {
    @ObservedObject var gamificationSystem: GamificationFacade
    @StateObject private var router = ScheduleRouter()

    @State private var selectedDate: Date = {
        #if DEBUG
        if let key = ProcessInfo.processInfo.environment["TIMEFLOW_TEST_DATE"],
           let date = Timetable.dateFormat.date(from: key) { return date }
        #endif
        return Date()
    }()
    @State private var testMessage = ""
    @State private var showingTestResult = false

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
        let lessons = gamificationSystem.lessons(on: selectedDate)
        return VStack(spacing: 0) {
            weekPicker
            List {
                if lessons.isEmpty {
                    Text("На цей день занять немає").foregroundColor(.secondary)
                }
                ForEach(lessons) { lesson in
                    HStack {
                        Button {
                            router.showDetails(for: lesson.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title).font(.headline)
                                Text(lesson.timeRange).monospacedDigit()
                                Text(lesson.details)
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

        }
        .navigationTitle("TimeFlow")
        .toolbar {
            Menu {
                let times = Set(["08:20", "08:30", "10:15", "10:25", "11:55", "12:15"] + lessons.map(\.timeSlot))
                ForEach(times.sorted(), id: \.self) { time in
                    Button(time) {
                        gamificationSystem.simulateTimeCheck(time: time, on: selectedDate)
                        let titles = lessons.filter { $0.timeSlot == time }.map(\.title)
                        testMessage = time + " · " + (titles.isEmpty ? "Пари не починаються" : titles.joined(separator: ", "))
                        showingTestResult = true
                    }
                }
            } label: {
                Text("Тест")
            }
        }
        .alert("Перевірка часу", isPresented: $showingTestResult) {
            Button("Гаразд") { }
        } message: {
            Text(testMessage)
        }
    }

    private var weekPicker: some View {
        let calendar = Timetable.calendar
        let days = Timetable.week(containing: selectedDate)
        let labels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Нд"]
        return VStack(spacing: 8) {
            HStack(spacing: 3) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                    let selected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let today = calendar.isDateInToday(date)
                    Button {
                        selectedDate = date
                    } label: {
                        VStack(spacing: 4) {
                            Text(labels[index]).font(.caption)
                            Text(String(calendar.component(.day, from: date))).font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(selected ? Color.accentColor.opacity(0.18) : .clear))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(today ? Color.accentColor : .clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            HStack {
                Button { moveWeek(-1) } label: { Image(systemName: "chevron.left") }
                    .accessibilityLabel("Попередній тиждень")
                Spacer()
                DatePicker("Дата розкладу", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "uk_UA"))
                    .environment(\.timeZone, calendar.timeZone)
                Spacer()
                Button { moveWeek(1) } label: { Image(systemName: "chevron.right") }
                    .accessibilityLabel("Наступний тиждень")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func moveWeek(_ offset: Int) {
        if let date = Timetable.calendar.date(byAdding: .weekOfYear, value: offset, to: selectedDate) {
            selectedDate = date
        }
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
