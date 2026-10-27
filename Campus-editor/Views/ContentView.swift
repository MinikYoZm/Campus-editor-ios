import SwiftUI

struct ContentView: View {
    // Взаємодіємо ТІЛЬКИ з Фасадом
    @StateObject private var gamificationSystem = GamificationFacade()
    
    var body: some View {
        NavigationView {
            VStack {
                // Блок тестування Observer
                HStack {
                    Button("Час: 08:20") { gamificationSystem.simulateTimeCheck(time: "08:20") }
                        .buttonStyle(.borderedProminent)
                    Button("Час: 08:30") { gamificationSystem.simulateTimeCheck(time: "08:30") }
                        .buttonStyle(.borderedProminent)
                    
                    Button("Час: 10:15") { gamificationSystem.simulateTimeCheck(time: "10:15") }
                        .buttonStyle(.borderedProminent)
                    Button("Час: 10:25") { gamificationSystem.simulateTimeCheck(time: "10:25") }
                        .buttonStyle(.borderedProminent)

                    Button("Час: 11:55") { gamificationSystem.simulateTimeCheck(time: "11:55") }
                        .buttonStyle(.borderedProminent)
                    Button("Час: 12:15") { gamificationSystem.simulateTimeCheck(time: "12:15") }
                        .buttonStyle(.borderedProminent)
                }
                .padding(.top)

                List {
                    ForEach(gamificationSystem.displayLessons) { lesson in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title).font(.headline)
                                Text("\(lesson.timeSlot) - \(lesson.weekday.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Відображення опціональних полів
                                if let link = lesson.meetingLink, !link.isEmpty {
                                    Text("🔗 \(link)").font(.caption).foregroundColor(.blue)
                                }
                                if let notes = lesson.notes, !notes.isEmpty {
                                    Text("📝 \(notes)").font(.caption).foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Button(action: {
                                gamificationSystem.completeQuest(id: lesson.id)
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
            }
            .navigationTitle("TimeFlow Квести")
        }
    }
}
