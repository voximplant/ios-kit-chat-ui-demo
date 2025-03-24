//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

import Foundation

extension String {
    var containsSpecificSymbols: Bool {
        guard let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9$\\-_.+!*'(),:@&=]+$") else { return true }
        let range = NSRange(location: .zero, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) == nil
    }

    var localized: String {
        let localizedKey = String.LocalizationValue(stringLiteral: self)
        return String(localized: localizedKey)
    }

    func localized(args: CVarArg...) -> String {
         return String(format: localized, arguments: args)
     }
}
