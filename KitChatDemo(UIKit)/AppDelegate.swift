//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
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

    override init() {
        super.init()
        configureDependencies()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if !granted { print("Permission for push notifications denied.") }
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Self.deviceTokenSubject.send(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let viKitChatUI: VIKitChatUI = dependencies.resolve() else {
            completionHandler(.noData)
            return
        }
        viKitChatUI.handlePushNotification(userInfo) { error in
            completionHandler(.noData)
            guard let error else { return }
            print(error.description)
        }
    }

    private func configureDependencies() {
        let config = VIKitChatConfiguration()
        if let viKitChatUI = VIKitChatUI(
            accountRegion: accountRegion ?? "",
            channelUuid: channelUuid ?? "",
            token: token ?? "",
            clientId: clientId ?? "",
            configuration: config
        ) {
            dependencies.register(service: viKitChatUI)
        }
    }
}
