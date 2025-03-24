//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

enum ValidationError: CustomStringConvertible, Error {
    case empty
    case limit(limit: Int)
    case invalidValue

    var description: String {
        switch self {
        case .empty:
            LocalizedStrings.emptyStringError.localized
        case .limit(let limit):
            LocalizedStrings.countLimitError.localized(args: limit)
        case .invalidValue:
            LocalizedStrings.invalidValueError.localized
        }
    }
}
