//
//  Copyright (c) 2011-2026, Zingaya, Inc. All rights reserved.
//

import UIKit

extension UIWindow {
    var visibleViewController: UIViewController? {
        return self.getVisibleViewControllerFrom(self.rootViewController)
    }

    private func getVisibleViewControllerFrom(_ viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return self.getVisibleViewControllerFrom(navigationController.visibleViewController)
        } else if let tabBarController = viewController as? UITabBarController {
            return self.getVisibleViewControllerFrom(tabBarController.selectedViewController)
        } else {
            if let presentedViewController = viewController?.presentedViewController {
                return self.getVisibleViewControllerFrom(presentedViewController)
            } else {
                return viewController
            }
        }
    }
}
