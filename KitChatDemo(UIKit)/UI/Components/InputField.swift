//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

import AutoLayoutBuilder
import UIKit

final class InputField: UIView {
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.isHidden = shouldHidePlaceholder
        }
    }

    var text: String {
        get {
            textView.text
        } set {
            textView.text = newValue
            textViewDidChange()
        }
    }

    override var inputAccessoryView: UIView? {
        get {
            textView.inputAccessoryView
        } set {
            textView.inputAccessoryView = newValue
        }
    }

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textView.becomeFirstResponder()
    }

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    var errorText: String = "" {
        didSet {
            errorLabel.text = errorText
            errorLabel.isHidden = false
            containerView.layer.borderColor = UIColor.red50.cgColor
        }
    }

    weak var delegate: UITextViewDelegate? {
        didSet {
            textView.delegate = delegate
        }
    }

    private let lineLimit: CGFloat = 7

    private enum Constants {
        static let viewCornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let subviewsHorizontalPadding: CGFloat = 12
        static let subviewsVerticalPadding: CGFloat = 10
        static let containerViewTopPadding: CGFloat = 6
        static let containerViewBottomPadding: CGFloat = 16
    }

    private lazy var containerView = UIView()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = FontSet.body
        textView.textContainerInset = UIEdgeInsets(top: Constants.subviewsVerticalPadding, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = .zero
        textView.textColor = .gray10
        textView.backgroundColor = .clear
        textView.tintColor = .purple40
        textView.showsVerticalScrollIndicator = false
        return textView
    }()

    private lazy var placeholderLabel: UILabel = {
        var label = UILabel()
        label.font = FontSet.body
        label.numberOfLines = 1
        label.textColor = .gray50
        return label
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = FontSet.bodySmall
        label.numberOfLines = 1
        label.textColor = .red50
        label.isHidden = true
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontSet.body
        label.textColor = .gray10
        return label
    }()

    private var textViewHeightConstraint: NSLayoutConstraint?
    private let textViewLineHeight = ceil(FontSet.body.lineHeight)
    private var textViewMinHeight: CGFloat
    private var shouldHidePlaceholder: Bool {
        placeholder.isEmpty || !text.isEmpty
    }

    override var tag: Int {
        get {
            textView.tag
        } set {
            textView.tag = newValue
        }
    }

    override init(frame: CGRect) {
        textViewMinHeight = textViewLineHeight
        super.init(frame: frame)
        configureViews()
        observeTextViewNotification()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        textViewMinHeight = textViewLineHeight
        super.init(coder: aDecoder)
    }

    private func configureViews() {
        containerView.layer.cornerRadius = Constants.viewCornerRadius
        containerView.layer.borderWidth = Constants.borderWidth
        containerView.layer.borderColor = UIColor.clear.cgColor
        containerView.backgroundColor = .gray90

        addSubview(titleLabel) {
            $0.top.horizontalEdges == Superview()
        }

        addSubview(containerView) {
            $0.top(Constants.containerViewTopPadding) == titleLabel.bottom
            $0.horizontalEdges == Superview()
            $0.bottom(-1 * Constants.containerViewBottomPadding) == Superview()
        }

        addSubview(errorLabel) {
            $0.bottom.horizontalEdges == Superview()
        }

        containerView.addSubview(placeholderLabel) {
            $0.verticalEdges(Constants.subviewsVerticalPadding).equalToSuperview()
            $0.horizontalEdges(Constants.subviewsHorizontalPadding).equalToSuperview()
        }

        containerView.addSubview(textView) {
            $0.store(.height, in: &textViewHeightConstraint) {
                $0.horizontalEdges(Constants.subviewsHorizontalPadding)
                    .top
                    .bottom(-1 * Constants.subviewsVerticalPadding)
                    .equalToSuperview()

                $0.height(equalTo: textViewMinHeight + Constants.subviewsVerticalPadding)
            }
        }
    }

    private func observeTextViewNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewDidChange),
            name: UITextView.textDidChangeNotification,
            object: textView
        )
    }

    @objc private func textViewDidChange() {
        placeholderLabel.isHidden = shouldHidePlaceholder
        errorLabel.isHidden = true
        containerView.layer.borderColor = UIColor.clear.cgColor
        updateTextViewHeight()
    }

    private func updateTextViewHeight() {
        let textViewLineCount = floor(self.textView.contentSize.height / textViewLineHeight)
        let textViewContentHeight = textViewLineHeight * textViewLineCount

        if textViewLineCount < lineLimit {
            self.textViewHeightConstraint?.constant = textViewContentHeight + Constants.subviewsVerticalPadding
        } else {
            self.textViewHeightConstraint?.constant = textViewLineHeight * lineLimit + Constants.subviewsVerticalPadding
        }
    }
}
