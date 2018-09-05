//
//  NoteEditWireframe.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//

import UIKit

protocol NoteEditNavigator: class {
    func unwindToNote()
}
///initialize our edit view controller and generate our view controller and pass the requirements
class NoteEditWireframe: Wireframe {
    private let navigator: NoteEditNavigator
    required init(useCaseProvider: ProtocolProvider, navigator: NoteEditNavigator) {
        self.navigator = navigator
        super.init(useCaseProvider: useCaseProvider)
    }
    func noteEdit() -> NoteEditViewController {
        do {
            let useCase: NoteEditUseCase = try useCaseProvider.provideProtocol()
            let viewModel = NoteEditViewModel(useCase: useCase, navigator: navigator)
            let viewController = NoteEditViewController(nibName: "NoteEditViewController",
                                                        bundle: nil)
            viewController.viewModel = viewModel
            return viewController
        } catch {
            debugPrint(error)
            fatalError()
        }
    }
}
