//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import RxSwift
///action for showing list of notes
public protocol NoteListUseCase {
    ///observe for notes changes
    func notes() -> Observable<[NoteProtocol]>
    ///choose one of notes to edit
    func select(note: NoteProtocol)
    ///create a note
    func create() -> Completable
}
