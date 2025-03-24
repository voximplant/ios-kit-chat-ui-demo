//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import AutoLayoutBuilder
import UIKit

protocol RegionPickerDelegate: AnyObject {
    func regionPicker(_ regionPickerViewController: RegionPickerViewController, didPickedRegion region: String)
    func regionPickerWasClosed(_ regionPickerViewController: RegionPickerViewController)
}

final class RegionPickerViewController: UIViewController {
    weak var delegate: RegionPickerDelegate?

    private lazy var regionPickerView = UIPickerView()

    private lazy var cancelButton: UIButton = {
        var attributedTitle = AttributedString(stringLiteral: LocalizedStrings.regionPickerCancelButton.localized)
        attributedTitle.font = FontSet.bodyLarge

        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.contentInsets = Constants.buttonContentInset
        buttonConfiguration.attributedTitle = attributedTitle
        buttonConfiguration.baseForegroundColor = .purple40

        let button = UIButton(configuration: buttonConfiguration)
        return button
    }()

    private lazy var selectButton: UIButton = {
        var attributedTitle = AttributedString(stringLiteral: LocalizedStrings.regionPickerSelectButton.localized)
        attributedTitle.font = FontSet.bodyLargeBold

        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.contentInsets = Constants.buttonContentInset
        buttonConfiguration.attributedTitle = attributedTitle
        buttonConfiguration.baseForegroundColor = .purple40

        let button = UIButton(configuration: buttonConfiguration)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedStrings.regionTitle.localized
        label.font = FontSet.bodyLargeBold
        return label
    }()

    private var lastPickedRegionIndex: Int?

    private let regions: [String] = [
        "ru",
        "ru2",
        "eu",
        "us",
        "br",
        "kz"
    ]

    private enum Constants {
        static let buttonContentInset = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        static let pickerRowHeight: CGFloat = 35
        static let pickerHeight: CGFloat = 160
        static let verticalPadding: CGFloat = 16
        static let pickerViewHorizontalPadding: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 16
        static let buttonTopPadding: CGFloat = 8
        static let buttonHorizontalPadding: CGFloat = 8
    }

    init(lastPickedRegion: String?) {
        self.lastPickedRegionIndex = regions.firstIndex { $0 == lastPickedRegion }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let lastPickedRegionIndex {
            regionPickerView.selectRow(lastPickedRegionIndex, inComponent: .zero, animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.regionPickerWasClosed(self)
    }

    private func configureViews() {
        view.backgroundColor = .gray100

        view.addSubview(regionPickerView) {
            $0.horizontalEdges(Constants.pickerViewHorizontalPadding) == Superview()
            $0.bottom == view.safeAreaLayoutGuide.bottom
            $0.height(equalTo: Constants.pickerHeight)
        }

        view.addSubview(cancelButton) {
            $0.leading(Constants.buttonHorizontalPadding).top(Constants.buttonTopPadding) == Superview()
            $0.bottom(-1 * Constants.buttonBottomPadding) == regionPickerView.top
        }

        view.addSubview(selectButton) {
            $0.trailing(-1 * Constants.buttonHorizontalPadding).top(Constants.buttonTopPadding) == Superview()
            $0.bottom(-1 * Constants.buttonBottomPadding) == regionPickerView.top
        }

        view.addSubview(titleLabel) {
            $0.centerX == Superview()
            $0.bottom == selectButton.bottom
            $0.top == selectButton.top
        }

        regionPickerView.delegate = self
        regionPickerView.dataSource = self
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func selectButtonTapped() {
        dismiss(animated: true)
        let pickedIndex = regionPickerView.selectedRow(inComponent: .zero)
        lastPickedRegionIndex = pickedIndex
        delegate?.regionPicker(self, didPickedRegion: regions[pickedIndex])
    }
}

extension RegionPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        regions.count
    }
}

extension RegionPickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        regions[row]
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        Constants.pickerRowHeight
    }
}
