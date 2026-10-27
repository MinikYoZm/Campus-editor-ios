import SwiftUI

struct ContentView: View {
    // Створюємо зв'язок з нашою ViewModel
    @StateObject private var schedule = ScheduleManager()
    
    var body: some View {
        NavigationView {
            List {
                // SwiftUI автоматично розрізняє елементи завдяки Identifiable (id: UUID)
                ForEach(schedule.lessons) { lesson in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(lesson.title)
                                .font(.headline)
                            Text("\(lesson.timeSlot) - \(lesson.lecturer)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Кнопка виконання квесту (ДІЯ)
                        Button(action: {
                            // View викликає метод у ViewModel
                            schedule.completeQuestInSchedule(id: lesson.id)
                        }) {
                            Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(lesson.isCompleted ? .green : .gray)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("TimeFlow Квести")
        }
    }
}
