//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import RxSwift
///our errors
public enum ProtocolProviderError: Error {
    case unsupportedUseCase
}

public protocol ProtocolProvider {
    func provideProtocol<T>() throws -> T
}
