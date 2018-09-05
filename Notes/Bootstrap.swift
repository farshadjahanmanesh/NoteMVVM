//
//  Bootstrap.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//

import Foundation
import UIKit

final class MainWireframe {
    private var window: UIWindow?
    private var noteListWireframe: NoteListWireframe!
    private let storageUseCaseProvider: ProtocolProvider
    private weak var navigationController: UINavigationController!
    init() {
        storageUseCaseProvider = StorageProvider()
        setupAppearance()
    }
    func setupAppearance() {
        UITableView.appearance().backgroundColor = UIColor.white
    }
    func configureMainInterface() {
        func embed(child: UISplitViewController, parent: UIViewController) {
            child.willMove(toParentViewController: parent)
            parent.view.addSubview(child.view)
            parent.addChildViewController(child)
            child.didMove(toParentViewController: parent)
            parent.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .regular),
                                              forChildViewController: child)
        }
        let window: UIWindow = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        
        let noteListWireFrame = NoteListWireframe(useCaseProvider: storageUseCaseProvider, navigator: self)
        let noteListViewController = noteListWireFrame.noteList()
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: noteListViewController, action: #selector(NoteListTableViewController.addAction(_:)))

        noteListViewController.navigationItem.rightBarButtonItem = rightBarButton

        let navigationController = UINavigationController(rootViewController: noteListViewController)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.navigationController = navigationController
        self.window = window
        self.noteListWireframe = noteListWireFrame
    }
}

extension MainWireframe: NoteListNavigator {
    func toNote() {
        let viewController: NoteEditViewController = NoteEditWireframe(useCaseProvider: storageUseCaseProvider, navigator: self)
            .noteEdit()
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension MainWireframe: NoteEditNavigator {
    func unwindToNote() {
        navigationController.popViewController(animated: true)
    }
}
