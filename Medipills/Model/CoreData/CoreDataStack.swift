//
//  CoreDataStack.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 13/06/2023.
//

import Foundation
import CoreData


open class CoreDataStack {
    
    // MARK: - Propreties
        
        private let name: String
        
    // MARK: - Initializer
        
        public init(name: String) {
            self.name = name
        }

    // MARK: - Singleton
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error : \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
           return persistentContainer.viewContext
       }

}
