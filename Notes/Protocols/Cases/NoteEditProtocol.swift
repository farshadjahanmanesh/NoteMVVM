//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import RxSwift
///actions used for editing notes
public protocol NoteEditUseCase {
    ///observb for content changes
    var content: Observable<String> { get }
    ///update a note
    func update(string: String)
    ///delete a note
    func delete() -> Completable
}
