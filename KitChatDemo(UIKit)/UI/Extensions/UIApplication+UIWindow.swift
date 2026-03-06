//
//  Copyright (c) 2011-2026, Voximplant, Inc. All rights reserved.
//

import UIKit

extension UIApplication {
    var firstWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first
    }
}
