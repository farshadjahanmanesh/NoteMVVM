//
//  NoteListTableViewController.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NoteListTableViewController: UITableViewController {
    var viewModel: NoteListViewModel!
    private let disposeBag: DisposeBag  = DisposeBag()
    private let cellReuseIdentifier = "noteCell"
    
    @objc func addAction(_ sender: UIBarButtonItem) {}
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        bindViewModel()
    }
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in }.asDriver(onErrorJustReturn: ())
        let add = rx.sentMessage(#selector(NoteListTableViewController.addAction(_:)))
            .map { _ in }.asDriver(onErrorJustReturn: ())
        let input = NoteListViewModel.Input(trigger: viewWillAppear,
                                            addNoteTrigger: add,
                                            selection: tableView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)
        output.addNote.drive().disposed(by: disposeBag)
        output.selectedNote.drive().disposed(by: disposeBag)
        let notes: Driver<[NoteListItemViewModel]> = output.notes
        notes.drive(tableView.rx.items(cellIdentifier: cellReuseIdentifier,
                                      cellType: NoteListTableViewCell.self)) { tv, vm, cell in
                                        cell.bind(vm)

            }.disposed(by: disposeBag)
    }
    private func configureTableView() {
        tableView.dataSource = nil
        let bundle = Bundle(for: NoteListTableViewCell.self)
        let cellNib = UINib(nibName: "NoteListTableViewCell", bundle: bundle)
        tableView.register(cellNib, forCellReuseIdentifier: cellReuseIdentifier)
    }
}
