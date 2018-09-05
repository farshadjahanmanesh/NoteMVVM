//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import CoreData
import RxSwift

///storage errors
enum StorageError: Error {
    case NoteNotCreated
}

final class Storage: NSObject {
    //RX Variables
    fileprivate var selectedNote: Variable<NoteProtocol?> = Variable(nil)
    fileprivate var allNotes: Variable<[NoteProtocol]> = Variable([NoteProtocol]())
    fileprivate var editingContent: Variable<String> = Variable("")
    
    //CoreData Variables
    private let persistentContainer: NSPersistentContainer
    fileprivate let readContext: NSManagedObjectContext
    fileprivate let writeContext: NSManagedObjectContext
    override init() {
        let momdName = "Notes"
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName,
                                                             withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        //initializing our container
        persistentContainer = NSPersistentContainer(name: momdName, managedObjectModel: mom)
        
        //load date
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error), \(storeDescription)")
            }
        })
        
        self.readContext = persistentContainer.viewContext
        self.readContext.automaticallyMergesChangesFromParent = true
        self.writeContext = persistentContainer.newBackgroundContext()
        super.init()
    }
    fileprivate func fetchNotes() {
        let moc = self.readContext
        do {
            let request: NSFetchRequest<NoteObject> = NoteObject.fetchRequest()
            let objects = try moc.fetch(request)
            let notes: [NoteProtocol] = objects.compactMap({ (object) -> NoteProtocol? in
                return object
            }).sorted(by: { (p1, p2) -> Bool in
                p1.date > p2.date
            })
            DispatchQueue.main.async {
                self.allNotes.value = notes
            }
        } catch {
            return
        }
    }
}


extension Storage: NoteListUseCase {
    func create() -> Completable {
        return Completable.create { [weak self] (completable) -> Disposable in
            guard let moc = self?.writeContext else {
                completable(.error(StorageError.NoteNotCreated))
                return Disposables.create{}
            }
            let item = NSEntityDescription.insertNewObject(forEntityName: "Note", into: moc) as! NoteObject
            item.content = ""
            do {
                try moc.save()
                DispatchQueue.main.async {
                    self?.allNotes.value.insert(item, at: 0)
                    self?.selectedNote.value = item
                    self?.editingContent.value = item.content ?? ""
                    completable(.completed)
                }
            } catch {
                completable(.error(StorageError.NoteNotCreated))
                debugPrint(error)
            }
            return Disposables.create{}
        }
    }
    func select(note: NoteProtocol) {
        selectedNote.value = note
        editingContent.value = note.text
    }
    func notes() -> Observable<[NoteProtocol]> {
        fetchNotes()
        return Observable.of(self.allNotes.asObservable()).merge()
    }
    
}

extension Storage: NoteEditUseCase {
    func delete() -> Completable {
        return Completable.create { [weak self] (completable) -> Disposable in
            guard let noteToDelete = self?.selectedNote.value else {
                completable(.error(StorageError.NoteNotCreated))
                return Disposables.create{}
            }
            let noteObjectId = (noteToDelete as! NoteObject).objectID
            if var allNotes = self?.allNotes.value {
                var indexOfDeletion: Int?
                for (index, note) in allNotes.enumerated() {
                    if (note as! NoteObject).objectID == noteObjectId {
                        indexOfDeletion = index
                        break
                    }
                }
                if indexOfDeletion != nil {
                    allNotes.remove(at: indexOfDeletion!)
                    DispatchQueue.main.async {
                        self?.allNotes.value = allNotes
                    }
                } else {
                    completable(.error(StorageError.NoteNotCreated))
                    return Disposables.create{}
                }
            }
            if let writeNote = self?.writeContext.object(with: noteObjectId) {
                self?.writeContext.delete(writeNote)
                do {
                    try self?.writeContext.save()
                    completable(.completed)
                } catch {
                    completable(.error(StorageError.NoteNotCreated))
                }
                
            }
            return Disposables.create{}
        }
    }
    func update(string: String) {
        editingContent.value = string
        (selectedNote.value as? NoteObject)?.content = string
        
     //   if readContext.hasChanges {
            let readedNoteId = (selectedNote.value as! NoteObject).objectID
            guard let writeNote = self.writeContext.object(with: readedNoteId) as? NoteObject else {
                return
            }
            writeNote.content = string
            writeNote.date = Date().timeIntervalSince1970
            do {
                try self.writeContext.save()
            } catch {
                debugPrint("couldn't save the note updated content")
            }
            
      //  }
    }
    var content: Observable<String> {
        return editingContent.asObservable()
    }
}

