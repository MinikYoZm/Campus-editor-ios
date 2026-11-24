import Combine
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
    @Environment(\.scenePhase) private var scenePhase
    private let clock = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State private var testMessage = ""
    @State private var showingTestResult = false

    var body: some View {
        navigation
            .onReceive(clock) { _ in gamificationSystem.refreshElapsedLessons() }
            .onChange(of: scenePhase) { phase in
                if phase == .active { gamificationSystem.refreshElapsedLessons() }
            }
    }

    @ViewBuilder
    private var navigation: some View {
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
            lessonList(lessons)
        }
        .navigationTitle("TimeFlow")
        .toolbar {
            ToolbarItem { timeMenu }
        }
        .alert("Перевірка часу", isPresented: $showingTestResult) {
            Button("Гаразд") { }
        } message: {
            Text(testMessage)
        }
    }

    private func lessonList(_ lessons: [Lesson]) -> some View {
        List {
            if lessons.isEmpty {
                Text("На цей день занять немає").foregroundColor(.secondary)
            }
            ForEach(lessons) { lesson in
                VStack(alignment: .leading, spacing: 4) {
                    lessonRow(lesson)
                    if let link = lesson.meetingLink, let url = URL(string: link) {
                        Link(link, destination: url)
                            .font(.caption)
                            .buttonStyle(.borderless)
                    }
                }
            }
        }
    }

    private func lessonRow(_ lesson: Lesson) -> some View {
        HStack {
            Button {
                router.showDetails(for: lesson.id)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(lesson.title).font(.headline)
                        if lesson.hasNote {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    Text(lesson.timeRange).monospacedDigit()
                    Text(lesson.details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(lesson.hasNote ? lesson.title + ", є нотатка" : lesson.title)
            .accessibilityIdentifier("open-\(lesson.title)")

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                    gamificationSystem.toggleCompletion(id: lesson.id)
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
            .accessibilityLabel(lesson.isCompleted ? "Зняти галочку" : "Позначити виконаним")
        }
    }

    private var timeMenu: some View {
        Menu("Тест") {
            ForEach(gamificationSystem.testTimes, id: \.self) { time in
                Button(time) { checkTime(time) }
            }
        }
    }

    private func checkTime(_ time: String) {
        let messages = gamificationSystem.simulateTimeCheck(time: time, on: selectedDate)
        let result = messages.isEmpty ? "Немає занять або нагадувань" : messages.joined(separator: "\n")
        testMessage = "\(time) · \(result)"
        showingTestResult = true
    }

    private var weekPicker: some View {
        VStack(spacing: 8) {
            HStack(spacing: 3) {
                ForEach(Timetable.week(containing: selectedDate), id: \.self) { date in
                    dayButton(for: date)
                }
            }
            weekControls
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func dayButton(for date: Date) -> some View {
        let calendar = Timetable.calendar
        let labels = ["Нд", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
        let label = labels[calendar.component(.weekday, from: date) - 1]
        let day = String(calendar.component(.day, from: date))
        let selected = calendar.isDate(date, inSameDayAs: selectedDate)
        let fill: Color = selected ? Color.accentColor.opacity(0.18) : Color.clear
        let border: Color = calendar.isDateInToday(date) ? Color.accentColor : Color.clear
        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text(label).font(.caption)
                Text(day).font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(RoundedRectangle(cornerRadius: 10).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(border, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? AccessibilityTraits.isSelected : [])
    }

    private var weekControls: some View {
        HStack {
            Button { moveWeek(-1) } label: { Image(systemName: "chevron.left") }
                .accessibilityLabel("Попередній тиждень")
            Spacer()
            DatePicker("Дата розкладу", selection: $selectedDate, displayedComponents: .date)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "uk_UA"))
                .environment(\.timeZone, Timetable.calendar.timeZone)
            Spacer()
            Button { moveWeek(1) } label: { Image(systemName: "chevron.right") }
                .accessibilityLabel("Наступний тиждень")
        }
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
