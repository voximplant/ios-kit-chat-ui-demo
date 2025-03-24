//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

import UIKit

final class PaddingLabel: UILabel {
    var insets: UIEdgeInsets

    required init(frame: CGRect = .zero, insets: UIEdgeInsets = .zero) {
        self.insets = insets
        super.init(frame: CGRect.zero)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        insets = .zero
        super.init(coder: aDecoder)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += insets.top + insets.bottom
        contentSize.width += insets.left + insets.right
        return contentSize
    }
}
