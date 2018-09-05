//
//  NoteListTableViewCell.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import UIKit

class NoteListTableViewCell: UITableViewCell {
    func bind(_ viewModel: NoteListItemViewModel) {
        self.detailTextLabel?.attributedText = NSAttributedString(string: viewModel.subtitle)
        if !viewModel.title.isEmpty {
            self.textLabel?.text = viewModel.title
        } else {
            textLabel?.text = NSLocalizedString("New Note...", comment: "")
        }
    }
}
