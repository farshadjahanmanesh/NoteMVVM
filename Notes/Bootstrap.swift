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
    //storage protocol
    private let storageUseCaseProvider: ProtocolProvider
    
    //main navigation controller
    private weak var navigationController: UINavigationController!
    init() {
        //initializa CoreData and storage
        storageUseCaseProvider = StorageProvider()
        
        //setup some appearance
        setupAppearance()
    }
    private func setupAppearance() {
        UITableView.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = .black
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
        //generate and assign our main view controller which is note list
        let noteListWireFrame = NoteListWireframe(useCaseProvider: storageUseCaseProvider, navigator: self)
        let noteListViewController = noteListWireFrame.noteList()
        
        //add a button for inserting new note
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: noteListViewController, action: #selector(NoteListTableViewController.addAction(_:)))
        
        //config our view controller
        noteListViewController.navigationItem.rightBarButtonItem = rightBarButton
        noteListViewController.title = "Notes"
        let navigationController = UINavigationController(rootViewController: noteListViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationItem.title  = "Notes"
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        //keep references
        self.navigationController = navigationController
        self.window = window
        self.noteListWireframe = noteListWireFrame
    }
}

extension MainWireframe: NoteListNavigator {
    //move to editing view controller
    func toNote() {
        let viewController: NoteEditViewController = NoteEditWireframe(useCaseProvider: storageUseCaseProvider, navigator: self)
            .noteEdit()
        viewController.title =  "Edit"
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension MainWireframe: NoteEditNavigator {
    //move back to notes lists
    func unwindToNote() {
        navigationController.popViewController(animated: true)
    }
}
