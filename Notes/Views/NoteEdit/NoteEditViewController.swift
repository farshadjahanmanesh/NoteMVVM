//
//  NoteEditViewController.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NoteEditViewController: UIViewController {
    @IBOutlet weak var textView: UITextView?
    var textDriver: Variable<String> = Variable("")
    var viewModel: NoteEditViewModel!
    var lastOffset: Int = 0
    private let disposeBag: DisposeBag = DisposeBag()
    override var inputAccessoryView: UIView? {
        get {
            return accessoryView
        }
    }
    var accessoryView: UIView?
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textView?.inputAccessoryView = nil
        bindViewModel()
        setupRightBarButton()
        setupTextView()
    }
    private func setupTextView() {
        textView?.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 64, right: 16)
    }
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in }.asDriver(onErrorJustReturn: ())
        let textTrigger: Driver<String> = textDriver.asObservable().skip(1).asDriver(onErrorJustReturn: "")
        let delete = rx.sentMessage(#selector(NoteEditViewController.trashNote)).map{_ in}.asDriver(onErrorJustReturn: ())
        let input = NoteEditViewModel.Input(trigger: viewWillAppear, deleteTrigger: delete, textTrigger: textTrigger)
        let output = viewModel.transform(input: input)
        output.text.drive(onNext: { [weak self] (attributedString) in
            self?.textView?.attributedText = attributedString
            if let newPosition = self?.textView?.position(from: self!.textView!.beginningOfDocument, offset: self!.lastOffset) {
                let textRange = self?.textView?.textRange(from: newPosition, to: newPosition)
                self?.textView?.selectedTextRange = textRange
            }
        }).disposed(by: disposeBag)
        
        output.textUpdate.drive().disposed(by: disposeBag)
        output.deleteUpdate.drive().disposed(by: disposeBag)
    }
    private func setupRightBarButton() {
        navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .trash,
                                                             target: self,
                                                             action: #selector(trashNote))
    }
    @objc private func trashNote() {}
}

extension NoteEditViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty {
            self.lastOffset = range.lowerBound
        } else {
            self.lastOffset = range.lowerBound - range.length + text.count
        }
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        self.textDriver.value = updatedText
        return false
    }
}
