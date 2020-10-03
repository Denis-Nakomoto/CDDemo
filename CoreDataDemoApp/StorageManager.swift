//
//  StorageManager.swift
//  CoreDataDemoApp
//
//  Created by Denis Svetlakov on 01.10.2020.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemoApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData(context: NSManagedObjectContext, completion:@escaping (_ tasks: [Task])->()) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let tasks = try context.fetch(fetchRequest)
            completion(tasks)
        } catch let error {
            print(error)
        }
    }
    
    func saveData(_ taskName: String?, _ context: NSManagedObjectContext, completion:@escaping (_ tasks: Task)->()) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.name = taskName
        completion(task)
        saveContext(context)
    }
    
    func deleteData(_ task: Task, _ context: NSManagedObjectContext) {
        context.delete(task)
        saveContext(context)
    }
    
}

