//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

import UIKit
import VoximplantKitChatUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let navController = UINavigationController(rootViewController: buildRootViewController())
        navController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navController
        self.window = window
        self.window?.makeKeyAndVisible()
    }

    private func buildRootViewController() -> KitChatDemoViewController {
        let viKitChatUI: VIKitChatUI? = ServiceLocator.shared.resolve()
        return KitChatDemoViewController(viKitChatUI: viKitChatUI)
    }
}
