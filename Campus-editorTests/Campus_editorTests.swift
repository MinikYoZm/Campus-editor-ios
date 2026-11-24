import XCTest
@testable import Campus_editor

private final class RecordingObserver: EventObserver {
    private(set) var messages: [String] = []

    func update(message: String) {
        messages.append(message)
    }
}

final class Campus_editorTests: XCTestCase {
    func testTimeCheckNotifiesAtReminderAndStart() throws {
        let observer = RecordingObserver()
        let facade = GamificationFacade(scheduleManager: ScheduleManager(), observer: observer)

        let date = try XCTUnwrap(Timetable.dateFormat.date(from: "2026-11-24"))
        let lessons = facade.lessons(on: date)
        XCTAssertEqual(lessons.map(\.timeSlot), ["12:20", "14:15"])

        facade.simulateTimeCheck(time: "08:20", on: date)
        XCTAssertTrue(observer.messages.isEmpty)

        XCTAssertEqual(facade.testTimes, ["08:20", "08:30", "10:15", "10:25", "12:10", "12:20",
                                          "14:05", "14:15", "16:00", "16:10", "17:55", "18:05"])
        XCTAssertEqual(facade.simulateTimeCheck(time: "12:10", on: date).count, 1)
        XCTAssertTrue(observer.messages.first?.contains("Через 10 хвилин") == true)

        facade.simulateTimeCheck(time: "12:20", on: date)
        XCTAssertEqual(observer.messages.count, 2)
        XCTAssertTrue(observer.messages.first?.contains("Паралельні та розподілені обчислення") == true)
    }

    func testAutomaticCheckmarkAppearsAtEndOfLesson() throws {
        let lesson = try XCTUnwrap(Timetable.load().first)
        let end = try XCTUnwrap(lesson.endDate)
        XCTAssertFalse(lesson.completed(at: end.addingTimeInterval(-1)))
        XCTAssertTrue(lesson.completed(at: end))
    }

    func testEditedAndClearedNotesSurviveReload() throws {
        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        func reload() throws -> ScheduleManager {
            let manager = ScheduleManager(defaults: defaults)
            let lesson = try XCTUnwrap(Timetable.load().first(where: { $0.hasNote }))
            manager.addLesson(lesson)
            return manager
        }

        let first = try reload()
        var draft = try XCTUnwrap(first.lessons.first)
        draft.notes = "Оновлена нотатка"
        first.updateLesson(draft)

        let reopened = try reload()
        draft = try XCTUnwrap(reopened.lessons.first)
        XCTAssertEqual(draft.notes, "Оновлена нотатка")
        draft.notes = nil
        reopened.updateLesson(draft)
        let cleared = try reload()
        XCTAssertNil(try XCTUnwrap(cleared.lessons.first).notes)
    }

    func testPastLessonCanBeUncheckedAcrossReloads() throws {
        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        var lesson = try XCTUnwrap(Timetable.load().first)
        lesson.dateKey = "2000-01-01"
        func loadFacade() -> GamificationFacade {
            GamificationFacade(scheduleManager: ScheduleManager(defaults: defaults),
                               observer: RecordingObserver(), lessons: [lesson])
        }
        let facade = loadFacade()
        XCTAssertTrue(try XCTUnwrap(facade.displayLessons.first).isCompleted)
        facade.toggleCompletion(id: lesson.id)
        let reopened = loadFacade()
        XCTAssertFalse(try XCTUnwrap(reopened.displayLessons.first).isCompleted)
        reopened.toggleCompletion(id: lesson.id)
        XCTAssertTrue(try XCTUnwrap(reopened.displayLessons.first).isCompleted)
    }
}
