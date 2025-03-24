//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import AutoLayoutBuilder
import UIKit

final class BannerView: UIView {
    private var currentStyle: BannerViewStyle = .error

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = FontSet.bodyBold
        label.textColor = .gray10
        label.numberOfLines = .zero
        return label
    }()

    private let retryLabel: PaddingLabel = {
        let label = PaddingLabel(insets: Constants.retryLabelInsets)
        label.font = FontSet.bodyBold
        label.textColor = .red50
        label.text = LocalizedStrings.bannerRetryLabel.localized
        return label
    }()

    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .fail.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .red50
        return imageView
    }()

    private let activityIndicatorView = UIActivityIndicatorView()

    private let containerView = UIView()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = .zero
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.contentMode = .center
        return stackView
    }()

    private enum Constants {
        static let bannerSubviewsPadding: CGFloat = 12
        static let bannerViewCornerRadius: CGFloat = 16
        static let animationDuration: CGFloat = 0.3
        static let selectedViewAlpha: CGFloat = 0.6
        static let iconSize: CGFloat = 32
        static let retryLabelInsets = UIEdgeInsets(top: .zero, left: 38, bottom: .zero, right: .zero)
        static let messageLabelLeadingPadding: CGFloat = 6
        static let messageLabelVerticalPadding: CGFloat = 6
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = Constants.bannerViewCornerRadius
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard currentStyle.shouldBeTapable else { return }
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .allowUserInteraction) {
                self.alpha = Constants.selectedViewAlpha
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard currentStyle.shouldBeTapable else { return }
        DispatchQueue.main.async {
            self.alpha = Constants.selectedViewAlpha
            UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .allowUserInteraction) {
                self.alpha = 1.0
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard currentStyle.shouldBeTapable else { return }
        DispatchQueue.main.async {
            self.alpha = Constants.selectedViewAlpha
            UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .allowUserInteraction) {
                self.alpha = 1.0
            }
        }
    }

    func configure(style: BannerViewStyle) {
        currentStyle = style
        isUserInteractionEnabled = style.shouldBeTapable

        UIView.animate(withDuration: Constants.animationDuration) {
            self.backgroundColor = style.backgroundColor
        }

        messageLabel.text = style.bannerMessage

        switch style {
        case .error:
            retryLabel.isHidden = false
            errorImageView.isHidden = false
            activityIndicatorView.isHidden = true
        case .loading:
            retryLabel.isHidden = true
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            errorImageView.isHidden = true
        }
    }

    private func configureView() {
        addSubview(stackView) {
            $0.edges(Constants.bannerSubviewsPadding) == Superview()
        }

        containerView.addSubview(errorImageView) {
            $0.size(equalTo: Constants.iconSize)
            $0.top.leading == Superview()
        }

        containerView.addSubview(activityIndicatorView) {
            $0.size(equalTo: Constants.iconSize)
            $0.top.leading == Superview()
        }

        containerView.addSubview(messageLabel) {
            $0.leading(Constants.messageLabelLeadingPadding) == errorImageView.trailing
            $0.verticalEdges(Constants.messageLabelVerticalPadding).trailing == Superview()
        }

        stackView.addArrangedSubview(containerView)
        stackView.addArrangedSubview(retryLabel)
    }
}
