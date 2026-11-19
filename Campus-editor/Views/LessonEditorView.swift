import SwiftUI

struct LessonEditorView: View {
    @State private var draft: Lesson
    let onSave: (Lesson) -> Void
    let onCancel: () -> Void

    init(lesson: Lesson, onSave: @escaping (Lesson) -> Void, onCancel: @escaping () -> Void) {
        _draft = State(initialValue: lesson)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    private var validTime: Bool {
        draft.timeSlot.range(of: #"^([01][0-9]|2[0-3]):[0-5][0-9]$"#, options: .regularExpression) != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Назва заняття") {
                    TextField("Назва", text: $draft.title)
                }
                Section("Час початку") {
                    TextField("ГГ:ХХ", text: $draft.timeSlot)
                    if !validTime {
                        Text("Введіть час від 00:00 до 23:59.").font(.caption)
                    }
                }
                Section("Нотатки") {
                    TextField("Нотатка", text: Binding(
                        get: { draft.notes ?? "" },
                        set: { draft.notes = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
            .navigationTitle("Редагування")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        draft.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(draft)
                    }
                    .disabled(!validTime || draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}
