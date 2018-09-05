//
//  NoteListWireframe.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//

import UIKit

protocol NoteListNavigator: class {
    func toNote()
}

class NoteListWireframe: Wireframe {
    private unowned var navigator: NoteListNavigator
    required init(useCaseProvider: ProtocolProvider, navigator: NoteListNavigator) {
        self.navigator = navigator
        super.init(useCaseProvider: useCaseProvider)
    }
    func noteList() -> UIViewController {
        do {
            let useCase: NoteListUseCase = try useCaseProvider.provideProtocol()
            let viewModel = NoteListViewModel(useCase: useCase, navigator: navigator)
            let viewController = NoteListTableViewController(nibName: "NoteListTableViewController",
                                                             bundle: nil)
            viewController.viewModel = viewModel
            return viewController
        } catch {
            debugPrint(error)
            fatalError()
        }
    }
}
