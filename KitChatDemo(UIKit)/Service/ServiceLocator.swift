//
//  Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
//

final class ServiceLocator {
    static let shared = ServiceLocator()

    private lazy var services: [String: Any] = [:]

    private init() {}

    private func typeName(_ some: Any) -> String {
        (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }

    func register<T>(service: T) {
        let key = typeName(T.self)
        services[key] = service
    }

    func resolve<T>() -> T? {
        let key = typeName(T.self)
        return services[key] as? T
    }
}
