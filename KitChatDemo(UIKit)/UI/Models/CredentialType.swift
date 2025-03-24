//
//  Copyright (c) 2011-2025, Zingaya, Inc. All rights reserved.
//

enum CredentialType {
    case region
    case channelUuid
    case token
    case clientId

    var textLimit: Int {
        switch self {
        case .region:
            Int.max
        case .channelUuid, .token:
            40
        case .clientId:
            100
        }
    }
}
