import XCTest
@testable import Campus_editor

private final class RecordingObserver: EventObserver {
    private(set) var messages: [String] = []

    func update(message: String) {
        messages.append(message)
    }
}

final class Campus_editorTests: XCTestCase {
    func testTimeCheckNotifiesObserverOnlyAtLessonTime() {
        let observer = RecordingObserver()
        let facade = GamificationFacade(scheduleManager: ScheduleManager(), observer: observer)

        facade.simulateTimeCheck(time: "08:20")
        XCTAssertTrue(observer.messages.isEmpty)

        facade.simulateTimeCheck(time: "08:30")
        XCTAssertEqual(observer.messages.count, 1)
        XCTAssertTrue(observer.messages.first?.contains("PRO") == true)
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
