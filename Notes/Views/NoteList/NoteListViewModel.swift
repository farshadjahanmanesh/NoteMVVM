//
//  NoteListViewModel.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa

final class NoteListViewModel: ViewModelProtocol {
    struct Input {
        let trigger: Driver<Void>
        let addNoteTrigger: Driver<Void>
        let selection: Driver<IndexPath>
    }
    struct Output {
        let notes: Driver<[NoteListItemViewModel]>
        let addNote: Driver<Void>
        let selectedNote: Driver<NoteProtocol>
    }
    private let disposeBag = DisposeBag()
    private let useCase: NoteListUseCase
    private unowned var navigator: NoteListNavigator
    init(useCase: NoteListUseCase, navigator: NoteListNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    func transform(input: Input) -> Output {
        let notes = input.trigger.flatMapLatest { [weak self] (_) -> SharedSequence<DriverSharingStrategy, [NoteListItemViewModel]> in
            return (self?.useCase.notes().asDriver(onErrorJustReturn: [NoteProtocol]())
                .map { $0.map { NoteListItemViewModel(with: $0) }
                })!
        }
        let selectedNote = input.selection.withLatestFrom(notes) { (indexPath, notes) -> NoteProtocol in
            return notes[indexPath.row].note
            }.do(onNext: { [weak self] (note) in
                self?.useCase.select(note: note)
                self?.navigator.toNote()
            })
        let createNote = input.addNoteTrigger
            .throttle(1)
            .do(onNext: {
                self.useCase.create()
                    .subscribe { [weak self] completable in
                    switch completable {
                    case .completed:
                        self?.navigator.toNote()
                    case .error(let error):
                        print("Completed with an error: \(error.localizedDescription)")
                    }
                    }
                    .disposed(by: self.disposeBag)
                
            })
        let output = Output(notes: notes, addNote: createNote, selectedNote: selectedNote)
        return output
    }
}
