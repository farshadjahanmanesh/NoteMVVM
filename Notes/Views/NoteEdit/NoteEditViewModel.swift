//
//  NoteEditViewModel.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NoteEditViewModel: ViewModelProtocol {
    struct Input {
        let trigger: Driver<Void>
        let deleteTrigger: Driver<Void>
        let textTrigger: Driver<String>
    }
    struct Output {
        let text: Driver<NSAttributedString>
        let textUpdate: Driver<Void>
        let deleteUpdate: Driver<Void>
    }
    private let disposeBag = DisposeBag()
    private let useCase: NoteEditUseCase
    private let navigator: NoteEditNavigator
    init(useCase: NoteEditUseCase, navigator: NoteEditNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    func transform(input: Input) -> Output {
        let text = input.trigger.flatMapLatest { [weak self] (_) -> SharedSequence<DriverSharingStrategy, NSAttributedString> in
            return (self?.useCase.content.asDriver(onErrorJustReturn: "").map {
                let noteItem = NoteEditItemViewModel(with: $0)
                return noteItem.attributedString
                })!
        }
        let inputText = input.textTrigger.do(onNext: { [weak self] (inputString) in
            self?.useCase.update(string: inputString)
        }).map{_ in}
        let deleteTrigger = input.deleteTrigger.do(onNext: { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            self?.useCase.delete().subscribe { [weak self] completable in
                switch completable {
                case .completed:
                    self?.navigator.unwindToNote()
                case .error(let error):
                    print("Completed with an error: \(error.localizedDescription)")
                }
                }.disposed(by: strongSelf.disposeBag)
        }).map{_ in}
        return Output(text: text, textUpdate: inputText, deleteUpdate: deleteTrigger)
    }
}
