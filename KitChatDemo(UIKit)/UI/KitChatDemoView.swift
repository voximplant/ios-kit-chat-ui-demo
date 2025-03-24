//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import AutoLayoutBuilder
import UIKit

final class KitChatDemoView: UIView {
    lazy var openChatButton: UIButton = {
        var attributedString = AttributedString(stringLiteral: LocalizedStrings.openChatButtonTitle.localized)
        attributedString.font = FontSet.bodyLargeSemiBold

        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .purple40
        buttonConfiguration.background.cornerRadius = Constants.buttonCornerRadius
        buttonConfiguration.attributedTitle = attributedString
        let button = UIButton(configuration: buttonConfiguration)

        return button
    }()

    lazy var allowNotificationsButton: UIButton = {
        var attributedString = AttributedString(stringLiteral: LocalizedStrings.allowNotificationsButtonTitle.localized)
        attributedString.font = FontSet.bodyLargeSemiBold

        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .purple90
        buttonConfiguration.baseForegroundColor = .purple40
        buttonConfiguration.background.cornerRadius = Constants.buttonCornerRadius
        buttonConfiguration.attributedTitle = attributedString
        buttonConfiguration.image = UIImage.notificationOn.withRenderingMode(.alwaysTemplate)
        buttonConfiguration.imagePadding = Constants.buttonImagePadding

        let button = UIButton(configuration: buttonConfiguration)
        button.isHidden = true
        return button
    }()

    lazy var regionView = RegionView()

    lazy var credentialsView = UIView()

    lazy var scrollView = UIScrollView()

    lazy var bannerView: BannerView = {
        let bannerView = BannerView()
        bannerView.alpha = .zero
        return bannerView
    }()

    lazy var channelUuidInputField: InputField = {
        let inputField = InputField()
        inputField.placeholder = LocalizedStrings.channelUuidPlaceholder.localized
        inputField.title = LocalizedStrings.channelUuidTitle.localized
        inputField.tag = InputFieldTags.channelUuidInputField.rawValue
        return inputField
    }()

    lazy var tokenInputField: InputField = {
        let inputField = InputField()
        inputField.placeholder = LocalizedStrings.tokenPlaceholder.localized
        inputField.title = LocalizedStrings.tokenTitle.localized
        inputField.tag = InputFieldTags.tokenInputField.rawValue
        return inputField
    }()

    lazy var clientIdInputField: InputField = {
        let inputField = InputField()
        inputField.placeholder = LocalizedStrings.clientIdPlaceholder.localized
        inputField.title = LocalizedStrings.clientIdTitle.localized
        inputField.tag = InputFieldTags.clientIdInputField.rawValue
        return inputField
    }()

    private var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .logo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var regionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedStrings.regionTitle.localized
        label.font = FontSet.body
        label.textColor = .gray10
        return label
    }()

    private lazy var regionErrorLabel: UILabel = {
        let label = UILabel()
        label.font = FontSet.bodySmall
        label.numberOfLines = 1
        label.textColor = .red50
        label.isHidden = true
        return label
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Constants.buttonsStackViewSpacing
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.contentMode = .center
        return stackView
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray100
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.credentialsViewCornerRadius
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()

    private lazy var leftSquareView: TransparentSquareView = {
        let view = TransparentSquareView()
        view.rotate(angle: -1 * Constants.leftSquareRotationAngle)
        return view
    }()

    private lazy var rightSquareView: TransparentSquareView = {
        let view = TransparentSquareView()
        view.rotate(angle: Constants.rightSquareRotationAngle)
        return view
    }()

    private var keyboardHeight: CGFloat = .zero
    private var activeTextView: UIView?
    private var activeTextViewLastOrigin: CGPoint?
    private var showedBannerViewTopConstraint: NSLayoutConstraint?
    private var hiddenBannerViewTopConstraint: NSLayoutConstraint?

    private enum InputFieldTags: Int {
        case channelUuidInputField
        case tokenInputField
        case clientIdInputField
    }

    private enum Constants {
        static let leftSquareRotationAngle: CGFloat = 15
        static let rightSquareRotationAngle: CGFloat = 165
        static let credentialsViewCornerRadius: CGFloat = 20
        static let logoTopPadding: CGFloat = 25
        static let logoSize: CGFloat = 40
        static let squareVerticalPadding: CGFloat = 15
        static let squareHorizontalPadding: CGFloat = 28
        static let buttonCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 44
        static let regionTitleTopPadding: CGFloat = 20
        static let regionViewHeight: CGFloat = 40
        static let regionViewTopPadding: CGFloat = 6
        static let credentialsViewTopPadding: CGFloat = 25
        static let inputFieldTopPadding: CGFloat = 4
        static let channelUuidInputFieldTopPadding: CGFloat = 20
        static let credentialsSubviewsHorizontalPadding: CGFloat = 16
        static let buttonsStackViewBottomPadding: CGFloat = 16
        static let buttonsStackViewSpacing: CGFloat = 12
        static let scrollViewBottomPadding: CGFloat = 16
        static let toolBarButtonWidth: CGFloat = 30
        static let toolBarInitialRect = CGRect(x: .zero, y: .zero, width: 100, height: 100)
        static let buttonImagePadding: CGFloat = 6
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConstaints()
        configureDelegates()
        observeKeyboardNotifications()
        addInputAccessory(for: [channelUuidInputField, tokenInputField, clientIdInputField])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setRegionViewError(_ errorString: String) {
        regionView.hasError = true
        regionErrorLabel.text = errorString
        regionErrorLabel.isHidden = false
    }

    func resetRegionViewError() {
        regionView.hasError = false
        regionErrorLabel.isHidden = true
    }

    func showBannerView(with style: BannerViewStyle) {
        UIView.animate(withDuration: 0.3) {
            self.bannerView.alpha = 1.0
            self.bannerView.configure(style: style)
            self.hiddenBannerViewTopConstraint?.priority = .defaultLow
            self.showedBannerViewTopConstraint?.priority = .defaultHigh
            self.layoutIfNeeded()
        }
    }

    func hideBannerView() {
        UIView.animate(withDuration: 0.3) {
            self.bannerView.alpha = .zero
            self.showedBannerViewTopConstraint?.priority = .defaultLow
            self.hiddenBannerViewTopConstraint?.priority = .defaultHigh
            self.layoutIfNeeded()
        }
    }

    private func configureDelegates() {
        channelUuidInputField.delegate = self
        tokenInputField.delegate = self
        clientIdInputField.delegate = self
    }

    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(calculateScrollViewOffset),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }

    private func configureConstaints() {
        backgroundColor = UIColor.gray05

        // kitChatView
        addSubview(logoImageView) {
            $0.top(Constants.logoTopPadding) == safeAreaLayoutGuide.top
            $0.centerX == Superview()
            $0.size(equalTo: Constants.logoSize)
        }

        addSubview(leftSquareView) {
            $0.top(Constants.squareVerticalPadding) == logoImageView.top
            $0.trailing(-1 * Constants.squareHorizontalPadding) == logoImageView.leading
        }

        addSubview(rightSquareView) {
            $0.bottom(-1 * Constants.squareVerticalPadding) == logoImageView.bottom
            $0.leading(Constants.squareHorizontalPadding) == logoImageView.trailing
        }

        // Credentials view
        addSubview(cardView) {
            $0.top(Constants.credentialsViewTopPadding) == logoImageView.bottom
            $0.bottom == Superview()
            $0.horizontalEdges == Superview()
        }

        // Buttons
        buttonsStackView.addArrangedSubview(allowNotificationsButton)
        buttonsStackView.addArrangedSubview(openChatButton)

        cardView.addSubview(buttonsStackView) {
            $0.horizontalEdges(Constants.credentialsSubviewsHorizontalPadding) == Superview()
            $0.bottom(-1 * Constants.buttonsStackViewBottomPadding) == cardView.safeAreaLayoutGuide.bottom
        }

        allowNotificationsButton.height(equalTo: Constants.buttonHeight).activate()
        openChatButton.height(equalTo: Constants.buttonHeight).activate()

        // Card view
        cardView.addSubview(scrollView) {
            $0.top.horizontalEdges == Superview()
            $0.bottom(-1 * Constants.scrollViewBottomPadding) == buttonsStackView.top
        }

        scrollView.addSubview(credentialsView) {
            $0.edges == scrollView.contentLayoutGuide
            $0.width == scrollView.frameLayoutGuide.width
        }

        // Region selector
        credentialsView.addSubview(bannerView) {
            $0.top(Constants.regionTitleTopPadding) == Superview()
            $0.horizontalEdges(Constants.credentialsSubviewsHorizontalPadding) == Superview()
        }

        credentialsView.addSubview(regionTitleLabel) {
            $0.store(.top, in: &showedBannerViewTopConstraint) {
                $0.top(Constants.regionTitleTopPadding, priority: .defaultLow) == bannerView.bottom
            }
            $0.store(.top, in: &hiddenBannerViewTopConstraint) {
                $0.top(Constants.regionTitleTopPadding) == Superview()
            }
            $0.horizontalEdges(Constants.credentialsSubviewsHorizontalPadding) == Superview()
        }

        credentialsView.addSubview(regionView) {
            $0.top(Constants.regionViewTopPadding) == regionTitleLabel.bottom
            $0.horizontalEdges(Constants.credentialsSubviewsHorizontalPadding) == Superview()
            $0.height(equalTo: Constants.regionViewHeight)
        }

        credentialsView.addSubview(regionErrorLabel) {
            $0.top == regionView.bottom
            $0.horizontalEdges(Constants.credentialsSubviewsHorizontalPadding) == Superview()
        }

        // Channel ID input field
        credentialsView.addSubview(channelUuidInputField) {
            $0.top(Constants.channelUuidInputFieldTopPadding) == regionView.bottom
            $0.horizontalEdges(Constants.credentialsSubviewsHorizontalPadding) == Superview()
        }

        // Token input field
        credentialsView.addSubview(tokenInputField) {
            $0.top(Constants.inputFieldTopPadding) == channelUuidInputField.bottom
            $0.horizontalEdges(Constants.credentialsSubviewsHorizontalPadding) == Superview()
        }

        // Client ID input field
        credentialsView.addSubview(clientIdInputField) {
            $0.top(Constants.inputFieldTopPadding) == tokenInputField.bottom
            $0.horizontalEdges(Constants.credentialsSubviewsHorizontalPadding).bottom == Superview()
        }
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        let keyboardFrameEndKey = UIResponder.keyboardFrameEndUserInfoKey

        guard let keyboardFrameEnd = notification.userInfo?[keyboardFrameEndKey] as? NSValue,
              activeTextView != nil else {
            return
        }

        let keyboardHeight = keyboardFrameEnd.cgRectValue.height
        self.keyboardHeight = keyboardHeight

        let keyboardInset = UIEdgeInsets(top: .zero, left: .zero, bottom: keyboardHeight + safeAreaInsets.bottom, right: .zero)
        scrollView.contentInset = keyboardInset
        scrollView.scrollIndicatorInsets = keyboardInset
        calculateScrollViewOffset()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard activeTextView != nil else { return }
        scrollView.setContentOffset(.zero, animated: true)
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func calculateScrollViewOffset() {
        guard let activeTextView, let activeTextViewLastOrigin else { return }

        let scrollViewHeight = scrollView.frame.size.height
        let distanceToSuperviewBottom = cardView.frame.size.height - scrollViewHeight

        activeTextView.setNeedsLayout()
        activeTextView.layoutIfNeeded()

        let activeTextViewHeight = activeTextView.frame.size.height
        let distanceFromScrollTopToActiveTextView = scrollViewHeight - activeTextViewLastOrigin.y - activeTextViewHeight
        let distanceToBottom = distanceFromScrollTopToActiveTextView + distanceToSuperviewBottom

        let collapseSpace = keyboardHeight - distanceToBottom

        guard collapseSpace > .zero else { return }

        let contentOffset = CGPoint(x: .zero, y: collapseSpace)
        scrollView.setContentOffset(contentOffset, animated: true)
    }

    private func addInputAccessory(for inputFields: [InputField]) {
        for (index, inputField) in inputFields.enumerated() {
            let toolbar = UIToolbar(frame: Constants.toolBarInitialRect)
            toolbar.barStyle = .default
            toolbar.isTranslucent = true
            toolbar.sizeToFit()

            var items: [UIBarButtonItem] = []

            let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
            previousButton.width = Constants.toolBarButtonWidth

            if inputField == inputFields.first {
                previousButton.isEnabled = false
            } else {
                previousButton.target = inputFields[index - 1]
                previousButton.action = #selector(UITextField.becomeFirstResponder)
            }
            previousButton.tintColor = .purple40

            let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
            nextButton.width = Constants.toolBarButtonWidth

            if inputField == inputFields.last {
                nextButton.isEnabled = false
            } else {
                nextButton.target = inputFields[index + 1]
                nextButton.action = #selector(UITextField.becomeFirstResponder)
            }
            nextButton.tintColor = .purple40

            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))
            doneButton.tintColor = .purple40

            items.append(contentsOf: [previousButton, nextButton, spacer, doneButton])

            toolbar.setItems(items, animated: false)
            inputField.inputAccessoryView = toolbar
        }
    }
}

// MARK: UITextViewDelegate
extension KitChatDemoView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView.tag {
        case InputFieldTags.channelUuidInputField.rawValue:
            activeTextView = channelUuidInputField
        case InputFieldTags.tokenInputField.rawValue:
            activeTextView = tokenInputField
        case InputFieldTags.clientIdInputField.rawValue:
            activeTextView = clientIdInputField
        default:
            activeTextView = nil
        }
        activeTextViewLastOrigin = activeTextView?.frame.origin
    }
}

@available(iOS 17.0, *)
#Preview {
    let viewController = UIViewController()
    viewController.navigationController?.setNavigationBarHidden(true, animated: false)
    viewController.view = KitChatDemoView()

    return viewController
}
