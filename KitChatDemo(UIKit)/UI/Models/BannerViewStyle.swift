//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

import UIKit

enum BannerViewStyle {
    case error
    case loading

    var backgroundColor: UIColor {
        switch self {
        case .error:
                .red95
        case .loading:
                .purple90
        }
    }

    var shouldBeTapable: Bool {
        switch self {
        case .error:
            true
        case .loading:
            false
        }
    }

    var bannerMessage: String {
        switch self {
        case .error:
            LocalizedStrings.bannerErrorMessage.localized
        case .loading:
            LocalizedStrings.bannerLoadingMessage.localized
        }
    }
}
