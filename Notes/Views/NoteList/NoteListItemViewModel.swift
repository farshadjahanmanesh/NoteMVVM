//
//  NoteListItemViewModel.swift
//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//

class NoteListItemViewModel {
    let title, subtitle: String
    let note: NoteProtocol
    init(with note: NoteProtocol) {
        self.note = note
        let text = note.text
        var lines = text.components(separatedBy: "\n")
        if lines.count > 1 {
            self.title = lines.first!
            lines.remove(at: 0)
            subtitle = lines.joined()
        } else {
            title = lines.first ?? ""
            subtitle = ""
        }
    }
}
