import Foundation

class LessonBuilder {
    private var title: String = ""
    private var weekday: WeekDay = .monday
    private var timeSlot: String = "00:00"
    private var meetingLink: String?
    private var notes: String?
    
    func setTitle(_ title: String) -> Self {
        self.title = title
        return self
    }
    
    func setTime(day: WeekDay, time: String) -> Self {
        self.weekday = day
        self.timeSlot = time
        return self
    }
    
    func setLink(_ link: String) -> Self {
        self.meetingLink = link
        return self
    }
    
    func setNotes(_ notes: String) -> Self {
        self.notes = notes
        return self
    }
    
    func build() -> Lesson {
        return Lesson(
            title: title,
            weekday: weekday,
            timeSlot: timeSlot,
            meetingLink: meetingLink,
            notes: notes
        )
    }
}
