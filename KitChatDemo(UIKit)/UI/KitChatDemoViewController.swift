//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import Combine
import UIKit
import VoximplantKitChatUI

final class KitChatDemoViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    @UserDefault("accountRegion") private var accountRegion: String?
    @UserDefault("channelUuid") private var channelUuid: String?
    @UserDefault("clientId") private var clientId: String?
    @UserDefault("token") private var token: String?

    private var regionView: RegionView?
    private var channelUuidInputField: InputField?
    private var tokenInputField: InputField?
    private var clientIdInputField: InputField?
    private var allowNotificationsButton: UIButton?

    private var pickedRegion = ""
    private var channelUuidTextFieldText: String {
        let text = channelUuidInputField?.text ?? ""
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        channelUuidInputField?.text = trimmedText
        return trimmedText
    }
    private var clientIdTextFieldText: String {
        let text = clientIdInputField?.text ?? ""
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        clientIdInputField?.text = trimmedText
        return trimmedText
    }
    private var tokenTextFieldText: String {
        let text = tokenInputField?.text ?? ""
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        tokenInputField?.text = trimmedText
        return trimmedText
    }
    private lazy var regionPickerViewController: RegionPickerViewController = {
        let regionPickerViewController = RegionPickerViewController(lastPickedRegion: accountRegion)
        regionPickerViewController.modalPresentationStyle = .custom
        regionPickerViewController.transitioningDelegate = slideInTransitioningDelegate
        regionPickerViewController.delegate = self
        return regionPickerViewController
    }()
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    private var kitChatId: UUID?
    private var viKitChatUI: VIKitChatUI?
    private lazy var kitChatDemoView = KitChatDemoView()
    private var deviceToken: Data?
    private var isDevelopment: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    private var isLastNotificationAccessIsGranted = false
    private var isCredentialsSameAsStored: Bool {
        pickedRegion == accountRegion &&
        channelUuidTextFieldText == channelUuid &&
        clientIdTextFieldText == clientId &&
        tokenTextFieldText == token
    }
    private lazy var regionViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(regionViewTapped))
    private lazy var bannerViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(bannerViewTapped))
    private var deviceTokenSubscription: AnyCancellable?

    init(viKitChatUI: VIKitChatUI?) {
        super.init(nibName: nil, bundle: nil)
        self.viKitChatUI = viKitChatUI
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        hideKeyboardWhenTappedAround()
        observeDidBecomeActiveNotification()
        observeDeviceTokenPublisher()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        regionView?.setRegion(accountRegion ?? "")
        pickedRegion = accountRegion ?? ""
        channelUuidInputField?.text = channelUuid ?? ""
        tokenInputField?.text = token ?? ""
        clientIdInputField?.text = clientId ?? ""
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.kitChatDemoView.scrollView.setNeedsLayout()
        self.kitChatDemoView.scrollView.layoutIfNeeded()
        self.kitChatDemoView.scrollView.contentSize = kitChatDemoView.credentialsView.frame.size
    }

    private func configureView() {
        view = kitChatDemoView
        self.allowNotificationsButton = kitChatDemoView.allowNotificationsButton
        kitChatDemoView.openChatButton.addTarget(self, action: #selector(openChatButtonTapped), for: .touchUpInside)
        allowNotificationsButton?.addTarget(self, action: #selector(allowNotificationsButtonTapped), for: .touchUpInside)
        kitChatDemoView.regionView.addGestureRecognizer(regionViewTapGesture)
        kitChatDemoView.bannerView.addGestureRecognizer(bannerViewTapGesture)
        regionView = kitChatDemoView.regionView
        channelUuidInputField = kitChatDemoView.channelUuidInputField
        tokenInputField = kitChatDemoView.tokenInputField
        clientIdInputField = kitChatDemoView.clientIdInputField
    }

    private func observeDidBecomeActiveNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func observeDeviceTokenPublisher() {
        deviceTokenSubscription = AppDelegate.deviceTokenPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] deviceToken in
                guard let self else { return }
                self.deviceToken = deviceToken
                self.registerPushToken(token: deviceToken)
            }
    }

    @objc private func regionViewTapped() {
        regionView?.rotateArrow()
        present(regionPickerViewController, animated: true)
    }

    @objc private func openChatButtonTapped() {
        guard let viKitChatUI = getVIKitChatUI() else { return }

        self.viKitChatUI = viKitChatUI

        guard let kitChatVC = VIKitChatViewController(id: viKitChatUI.id) else { return }
        navigationController?.pushViewController(kitChatVC, animated: true)
    }

    @objc private func allowNotificationsButtonTapped() {
        let alertController = UIAlertController(
            title: LocalizedStrings.allowNotificationsAlertTitle.localized,
            message: nil,
            preferredStyle: .alert
        )
        let actionClose = UIAlertAction(title: LocalizedStrings.allowNotificationsAlertCloseButton.localized, style: .default)
        let actionSettings = UIAlertAction(
            title: LocalizedStrings.allowNotificationsAlertSettingsButton.localized,
            style: .default
        ) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl) else {
                print("Unable to open application settings")
                return
            }
            UIApplication.shared.open(settingsUrl)
        }
        alertController.addAction(actionClose)
        alertController.addAction(actionSettings)
        alertController.preferredAction = actionSettings
        present(alertController, animated: true)
    }

    @objc private func bannerViewTapped() {
        guard let deviceToken, let viKitChatUI else { return }
        kitChatDemoView.bannerView.configure(style: .loading)

        viKitChatUI.registerPushToken(deviceToken, isDevelopment: isDevelopment) { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                if error == nil {
                    self.kitChatDemoView.hideBannerView()
                } else {
                    self.kitChatDemoView.showBannerView(with: .error)
                }
            }
        }
    }

    @objc private func didBecomeActiveNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied:
                    self.allowNotificationsButton?.isHidden = false
                    self.kitChatDemoView.hideBannerView()
                    self.isLastNotificationAccessIsGranted = false
                case .ephemeral, .authorized, .provisional:
                    self.allowNotificationsButton?.isHidden = true
                    if !self.isLastNotificationAccessIsGranted {
                        self.isLastNotificationAccessIsGranted = true
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }

    private func getVIKitChatUI() -> VIKitChatUI? {
        guard viKitChatUI == nil || !isCredentialsSameAsStored else { return viKitChatUI }

        let isValidCredentials = isValidCredentials()

        guard isValidCredentials,
              let viKitChatUI = VIKitChatUI(
                accountRegion: pickedRegion,
                channelUuid: channelUuidTextFieldText,
                token: tokenTextFieldText,
                clientId: clientIdTextFieldText
              )
        else { return nil }

        ServiceLocator.shared.register(service: viKitChatUI)

        accountRegion = pickedRegion
        channelUuid = channelUuidTextFieldText
        clientId = clientIdTextFieldText
        token = tokenTextFieldText

        registerPushToken(token: deviceToken)

        return viKitChatUI
    }

    private func registerPushToken(token: Data?) {
        guard let token else { return }
        viKitChatUI?.registerPushToken(token, isDevelopment: isDevelopment) { [weak self] error in
            guard let self, error != nil else { return }
            DispatchQueue.main.async {
                self.kitChatDemoView.showBannerView(with: .error)
            }
        }
    }

    private func isValidCredentials() -> Bool {
        let pickerRegionError = validate(pickedRegion, credentialType: .region)
        if let pickerRegionError {
            kitChatDemoView.setRegionViewError(pickerRegionError.description)
        }

        let channelUuidError = validate(channelUuidTextFieldText, credentialType: .channelUuid)
        if let channelUuidError {
            channelUuidInputField?.errorText = channelUuidError.description
        }

        let clientIdError = validate(clientIdTextFieldText, credentialType: .clientId)
        if let clientIdError {
            clientIdInputField?.errorText = clientIdError.description
        }

        let tokenError = validate(tokenTextFieldText, credentialType: .token)
        if let tokenError {
            tokenInputField?.errorText = tokenError.description
        }
        return pickerRegionError == nil && channelUuidError == nil && clientIdError == nil && tokenError == nil
    }

    private func validate(_ text: String, credentialType: CredentialType) -> ValidationError? {
        guard text.count > .zero else { return .empty }
        guard text.count <= credentialType.textLimit else { return .limit(limit: credentialType.textLimit) }
        guard !text.containsSpecificSymbols else { return .invalidValue }
        return nil
    }

    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension KitChatDemoViewController: RegionPickerDelegate {
    func regionPicker(_ regionPickerViewController: RegionPickerViewController, didPickedRegion region: String) {
        regionView?.setRegion(region)
        kitChatDemoView.resetRegionViewError()
        pickedRegion = region
    }

    func regionPickerWasClosed(_ regionPickerViewController: RegionPickerViewController) {
        regionView?.rotateArrow()
    }
}
