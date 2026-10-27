import Foundation

// Протокол Спостерігача (Підписника)
protocol EventObserver: AnyObject {
    func update(message: String)
}

// Протокол Видавця (Суб'єкта)
protocol EventSubject {
    func addObserver(_ observer: EventObserver)
    func notifyObservers(message: String)
}

// Конкретний Спостерігач
class PushNotificationService: EventObserver {
    func update(message: String) {
        print("[PUSH СПОВІЩЕННЯ]: \(message)")
    }
}
