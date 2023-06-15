//
//  MockCoreDataStack.swift
//  MedipillsTests
//
//  Created by Richard Arif Mazid on 14/06/2023.
//

import Foundation
import Medipills
import CoreData

final class MockCoreDataStack: CoreDataStack {
    
    convenience init() {
        self.init(name: "MedipillsModel")
    }
    
    override init(name: String) {
        super.init(name: name)
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        let container = NSPersistentContainer(name: name)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        self.persistentContainer = container
    }
}
