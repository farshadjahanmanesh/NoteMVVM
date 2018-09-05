//
//  Wireframe.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//

import Foundation
class Wireframe {
    private(set) var useCaseProvider: ProtocolProvider
    init(useCaseProvider: ProtocolProvider) {
        self.useCaseProvider = useCaseProvider
    }
}
//based on kistarter idiea , each viewmodel need to know its input and its out put, and transforms the input to output
protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
