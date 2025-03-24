//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

import Foundation

private let userDefaults = UserDefaults.standard

@propertyWrapper
struct UserDefault<Value> {
    let key: String

    init(_ key: String) {
        self.key = key
    }

    var wrappedValue: Value? {
        get { userDefaults.object(forKey: key) as? Value }
        set { userDefaults.set(newValue, forKey: key) }
    }
}
