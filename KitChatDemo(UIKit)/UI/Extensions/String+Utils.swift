//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import Foundation

extension String {
    var removedAllWhitespaces: Self {
        filter { !$0.isWhitespace }
    }
    
    var localized: Self {
        let localizedKey = Self.LocalizationValue(stringLiteral: self)
        return Self(localized: localizedKey)
    }

    func localized(args: CVarArg...) -> Self {
         return Self(format: localized, arguments: args)
     }
}
