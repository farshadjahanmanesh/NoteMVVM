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
    //keep a reference to our current and editing note
    fileprivate var selectedNote: Variable<NoteProtocol?> = Variable(nil)
    //a subject to subscribe for note changes
    fileprivate var allNotes: Variable<[NoteProtocol]> = Variable([NoteProtocol]())
    //a subject of string which is editing
    fileprivate var editingContent: Variable<String> = Variable("")
    
    //CoreData Variables
    private let persistentContainer: NSPersistentContainer
    fileprivate let readContext: NSManagedObjectContext
    fileprivate let writeContext: NSManagedObjectContext
    override init() {
        //managed object name
        let momdName = "Notes"
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName,
                                                             withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        //managed object model
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
        let reading = self.readContext
        do {
            let request: NSFetchRequest<NoteObject> = NoteObject.fetchRequest()
            let objects = try reading.fetch(request)
            //fetch items from storage and sort them based on editing date (recent/top)
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
            //get writing context
            guard let writingContext = self?.writeContext else {
                completable(.error(StorageError.NoteNotCreated))
                return Disposables.create{}
            }
            //create a new object
            let item = NSEntityDescription.insertNewObject(forEntityName: "Note", into: writingContext) as! NoteObject
            item.content = ""
            do {
                //update our context
                try writingContext.save()
                
                //notify our subscriptions and dispose this observable
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
        //notify our subscription that a note selected
        selectedNote.value = note
        editingContent.value = note.text
    }
    func notes() -> Observable<[NoteProtocol]> {
        //fetch notes and create a observale of them
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

