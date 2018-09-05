//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import Foundation
import CoreData

///CoreData: note representation
public class NoteObject: NSManagedObject {

}

///coredate note fields to note entities
extension NoteObject: NoteProtocol {
    public var text: String {
        get {
            return content ?? ""
        }
        set(newValue) {
            content = newValue
        }
    }
    public var date: Double {
            get {
                return createdAt ?? 0.0
            }
            set(newValue) {
                createdAt = newValue
            }
    }
}
