//
//  StorageProvider
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import RxSwift

public class StorageProvider: ProtocolProvider {
    let storage: Storage
    public init() {
        storage = Storage()
    }
    public func provideProtocol<T>() throws -> T {
        if let useCase: T = self.storage as? T {
            return useCase
        } else {
            throw ProtocolProviderError.unsupportedUseCase
        }
    }
}
