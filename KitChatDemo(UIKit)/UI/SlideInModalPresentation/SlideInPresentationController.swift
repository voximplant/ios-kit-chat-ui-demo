//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

import UIKit

final class SlideInPresentationController: UIPresentationController {
    // MARK: - Properties
    private var originalX: CGFloat = .zero
    private var originalY: CGFloat = .zero
    private var distance: CGFloat

    private var dimmingView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .black.withAlphaComponent(0.35)
        uiView.alpha = .zero
        return uiView
    }()

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        guard let containerView else { return .zero }
        frame.size = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )
        frame.origin.y = containerView.frame.height - distance
        return frame
    }

    private enum Constants {
        static let closeViewPercent = 0.7
        static let viewCornerRadius: CGFloat = 20.0
        static let animationsDuration: CGFloat = 0.25
        static let cornerRadius: CGFloat = 20
    }

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, distance: CGFloat) {
        self.distance = distance

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }

    override func presentationTransitionWillBegin() {
        containerView?.addSubview(dimmingView) {
            $0.edges.equalToSuperview()
        }
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        containerView?.addGestureRecognizer(viewPan)

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        coordinator.animate { _ in
            self.dimmingView.alpha = 1.0
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = .zero
            return
        }
        coordinator.animate { _ in
            self.dimmingView.alpha = .zero
        }
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = Constants.cornerRadius
        presentedView?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        CGSize(width: parentSize.width, height: distance)
    }
}

// MARK: - Private
private extension SlideInPresentationController {
    private func setupDimmingView() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }

    @objc private func viewPanned(_ sender: UIPanGestureRecognizer) {
        let translate = sender.translation(in: self.presentedView)
        switch sender.state {
        case .began:
            originalX = presentedViewController.view.frame.origin.x
            originalY = presentedViewController.view.frame.origin.y
        case .changed:
            if translate.y > .zero {
                presentedViewController.view.frame.origin.y = originalY + translate.y
            }
        case .ended:
            let presentedViewHeight = presentedViewController.view.frame.height
            let newY = presentedViewController.view.frame.origin.y

            let yDiff = newY - originalY
            let remainedViewHeight = presentedViewHeight - yDiff
            let allowedViewHeight = presentedViewHeight * Constants.closeViewPercent
            if remainedViewHeight > allowedViewHeight {
                setBackToOriginalPosition()
            } else {
                moveAndDismissPresentedView()
            }
        default:
            break
        }
    }

    private func setBackToOriginalPosition() {
        presentedViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: Constants.animationsDuration, delay: .zero, options: .curveEaseIn) {
            self.presentedViewController.view.frame.origin.y = self.originalY
            self.presentedViewController.view.layoutIfNeeded()
        }
    }

    private func moveAndDismissPresentedView() {
        presentedViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: Constants.animationsDuration, delay: .zero, options: .curveEaseIn) {
            self.presentedViewController.view.frame.origin.y = self.presentingViewController.view.frame.height
            self.presentedViewController.view.layoutIfNeeded()
        } completion: { _ in
            self.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}
