import XCTest
@testable import Campus_editor

private final class RecordingObserver: EventObserver {
    private(set) var messages: [String] = []

    func update(message: String) {
        messages.append(message)
    }
}

final class Campus_editorTests: XCTestCase {
    func testTimeCheckNotifiesObserverOnlyAtLessonTime() throws {
        let observer = RecordingObserver()
        let facade = GamificationFacade(scheduleManager: ScheduleManager(), observer: observer)

        let date = try XCTUnwrap(Timetable.dateFormat.date(from: "2026-11-24"))
        let lessons = facade.lessons(on: date)
        XCTAssertEqual(lessons.map(\.timeSlot), ["12:20", "14:15"])

        facade.simulateTimeCheck(time: "08:20", on: date)
        XCTAssertTrue(observer.messages.isEmpty)

        facade.simulateTimeCheck(time: "12:20", on: date)
        XCTAssertEqual(observer.messages.count, 1)
        XCTAssertTrue(observer.messages.first?.contains("Паралельні та розподілені обчислення") == true)
    }

    func testCompletingQuestUpdatesDisplayedLesson() throws {
        let facade = GamificationFacade(scheduleManager: ScheduleManager(), observer: RecordingObserver())
        let lesson = try XCTUnwrap(facade.displayLessons.first)
        XCTAssertFalse(lesson.isCompleted)

        facade.completeQuest(id: lesson.id)

        let updated = try XCTUnwrap(facade.displayLessons.first { $0.id == lesson.id })
        XCTAssertTrue(updated.isCompleted)
    }
}
