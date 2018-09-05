//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import Foundation
import CoreData

///CoreDate: Note Actions and Fields
extension NoteObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteObject> {
        return NSFetchRequest<NoteObject>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var createdAt: Double
}
