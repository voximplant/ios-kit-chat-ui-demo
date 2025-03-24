//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import AutoLayoutBuilder
import UIKit

final class RegionView: UIView {
    var hasError: Bool = false {
        didSet {
            if hasError {
                layer.borderColor = UIColor.red50.cgColor
            } else {
                layer.borderColor = UIColor.clear.cgColor
            }
        }
    }

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = FontSet.body
        label.textColor = .gray50
        label.text = LocalizedStrings.regionPlaceholder.localized
        return label
    }()

    private lazy var regionLabel: UILabel = {
        let label = UILabel()
        label.font = FontSet.body
        label.textColor = .gray10
        label.isHidden = true
        return label
    }()

    private lazy var arrowDown: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.arrowDown
        return imageView
    }()

    private enum Constants {
        static let animationDuration: CGFloat = 0.3
        static let rotationAngle: CGFloat = 180
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let selectedViewAlpha: CGFloat = 0.6
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .curveLinear) {
                self.alpha = Constants.selectedViewAlpha
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async {
            self.alpha = Constants.selectedViewAlpha
            UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .curveLinear) {
                self.alpha = 1.0
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        DispatchQueue.main.async {
            self.alpha = Constants.selectedViewAlpha
            UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .curveLinear) {
                self.alpha = 1.0
            }
        }
    }

    func setRegion(_ region: String) {
        if region.isEmpty {
            regionLabel.isHidden = true
            placeholderLabel.isHidden = false
            regionLabel.text = ""
        } else {
            regionLabel.isHidden = false
            placeholderLabel.isHidden = true
            regionLabel.text = region
        }
    }

    func rotateArrow() {
        UIView.animate(withDuration: Constants.animationDuration, delay: .zero, options: .curveEaseInOut) {
            self.arrowDown.rotate(angle: Constants.rotationAngle)
        }
    }

    private func configureViews() {
        backgroundColor = .gray90
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.clear.cgColor

        addSubview(placeholderLabel) {
            $0.leading(Constants.horizontalPadding).verticalEdges(Constants.verticalPadding) == Superview()
        }

        addSubview(regionLabel) {
            $0.leading(Constants.horizontalPadding).verticalEdges(Constants.verticalPadding) == Superview()
        }

        addSubview(arrowDown) {
            $0.trailing(-1 * Constants.horizontalPadding).verticalEdges(Constants.verticalPadding) == Superview()
        }
    }
}
