import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        guard settings.authorizationStatus == .notDetermined else {
            return
        }

        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("❌ Failed to request notification permission: \(error.localizedDescription)")
        }
    }

    func scheduleDocumentNotification(title: String, details: String) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            await requestAuthorizationIfNeeded()
        }

        let refreshedSettings = await center.notificationSettings()
        guard refreshedSettings.authorizationStatus == .authorized || refreshedSettings.authorizationStatus == .provisional else {
            print("⚠️ Notifications are not authorized by user")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = details
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        do {
            try await center.add(request)
            print("✅ Local notification scheduled")
        } catch {
            print("❌ Failed to schedule notification: \(error.localizedDescription)")
        }
    }
}