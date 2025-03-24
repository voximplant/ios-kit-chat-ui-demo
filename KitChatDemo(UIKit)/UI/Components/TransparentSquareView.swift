//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

import UIKit

final class TransparentSquareView: UIView {
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.purple40.cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        return gradientLayer
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = .clear
        return blurEffectView
    }()

    private lazy var blurGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        return gradientLayer
    }()

    private enum Constants {
        static let cornerRadius: CGFloat = 26
        static let squareSize: CGFloat = 134
        static let alpha: CGFloat = 0.5
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(blurEffectView)
        blurEffectView.layer.mask = blurGradientLayer
        blurEffectView.alpha = Constants.alpha
        size(equalTo: Constants.squareSize).activate()
        layer.cornerRadius = Constants.cornerRadius
        layer.addSublayer(gradientLayer)
        alpha = Constants.alpha
        clipsToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = layer.bounds
        blurEffectView.frame = layer.bounds
        blurGradientLayer.frame = layer.bounds
    }
}
