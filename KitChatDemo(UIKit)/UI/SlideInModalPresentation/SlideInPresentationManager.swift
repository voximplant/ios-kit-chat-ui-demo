//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

import UIKit

final class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    var distance: CGFloat

    init(distance: CGFloat = 210) {
        let window = UIApplication.shared.firstWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? .zero
        self.distance = distance + bottomPadding
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(
            presentedViewController: presented, presenting: presenting, distance: distance
        )
        return presentationController
    }
}
