//
//  Campus_editorUITests.swift
//  Campus-editorUITests
//
//  Created by Кулнаме on 29.09.2026.
//

import XCTest

final class Campus_editorUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    #if os(iOS)
    func testEditAndCancelFromSchedule() {
        let app = XCUIApplication()
        app.launch()

        let openLesson = app.buttons["open-PRO"]
        XCTAssertTrue(openLesson.waitForExistence(timeout: 5))
        capture(app, name: "01 Schedule")
        openLesson.tap()
        let edit = app.buttons["Редагувати"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5))
        capture(app, name: "02 Details")
        edit.tap()

        let notes = app.textFields["Нотатка"]
        XCTAssertTrue(notes.waitForExistence(timeout: 5))
        capture(app, name: "03 Editor")
        let title = app.textFields["Назва"]
        title.tap()
        // Коротке доповнення перевіряє, що збережена назва оновиться й у списку.
        title.typeText("1")
        let newTitle = title.value as? String ?? ""
        XCTAssertNotEqual(newTitle, "PRO")
        XCTAssertTrue(newTitle.contains("1"))
        app.buttons["Зберегти"].tap()
        XCTAssertTrue(app.staticTexts[newTitle].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let updated = app.buttons["open-" + newTitle]
        XCTAssertTrue(updated.waitForExistence(timeout: 5))
        updated.tap()
        edit.tap()
        notes.tap()
        notes.typeText("draft")
        app.buttons["Скасувати"].tap()
        XCTAssertTrue(edit.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["draft"].exists)
        edit.tap()
        XCTAssertTrue(notes.waitForExistence(timeout: 5))
        XCTAssertNotEqual(notes.value as? String, "draft")
    }

    private func capture(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    #endif

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
