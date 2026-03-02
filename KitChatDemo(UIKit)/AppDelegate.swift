//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import Combine
import UIKit
import VoximplantKitChatUI

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    static var deviceTokenPublisher: AnyPublisher<Data?, Never> {
        deviceTokenSubject.eraseToAnyPublisher()
    }

    @UserDefault("accountRegion") private var accountRegion: String?
    @UserDefault("channelUuid") private var channelUuid: String?
    @UserDefault("clientId") private var clientId: String?
    @UserDefault("token") private var token: String?
    private let dependencies = ServiceLocator.shared
    private static var deviceTokenSubject = PassthroughSubject<Data?, Never>()
    private var isPresentedVIKitChatViewController: Bool {
        UIApplication.shared.firstWindow?.visibleViewController is VIKitChatViewController
    }

    override init() {
        super.init()
        configureDependencies()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if !granted { print("Permission for push notifications denied.") }
        }
        notificationCenter.delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Self.deviceTokenSubject.send(deviceToken)
    }

    private func configureDependencies() {
        let config = VIKitChatConfiguration()
        guard let accountRegion,
              let viRegion = VIRegion(rawValue: accountRegion),
              let viKitChatUI = VIKitChatUI(
                accountRegion: viRegion,
                channelUuid: channelUuid ?? "",
                token: token ?? "",
                clientId: clientId ?? "",
                configuration: config
              ) else {
            return
        }
        dependencies.register(service: viKitChatUI)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        guard !isPresentedVIKitChatViewController else { return }
        completionHandler([.list, .banner, .sound])
    }
}
