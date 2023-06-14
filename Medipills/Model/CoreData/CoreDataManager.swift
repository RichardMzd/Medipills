//
//  CoreDataManager.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 13/06/2023.
//

import Foundation
import CoreData

class CoreDataManager {
    
    private let coreDataStack: CoreDataStack
    private let managedObjectContext: NSManagedObjectContext
    
    
//  MARK: - Initialization
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        self.managedObjectContext = coreDataStack.viewContext
    }
    
    var favoritesRecipes: [Drug] {
        let request: NSFetchRequest<Drug> = Drug.fetchRequest()
        guard let favoritesRecipes = try? managedObjectContext.fetch(request) else { return [] }
        return favoritesRecipes
    }
    
    // Enregistre un médicament dans la base de données CoreData
      func saveDrugToDatabase(localDrug: LocalDrug) {
          let managedContext = coreDataStack.persistentContainer.viewContext
          let entity = NSEntityDescription.entity(forEntityName: "Drug", in: managedContext)!
          let drug = NSManagedObject(entity: entity, insertInto: managedContext)
          
          drug.setValue(localDrug.name, forKey: "name")
          drug.setValue(localDrug.dose, forKey: "dose")
          drug.setValue(localDrug.time, forKey: "time")
          drug.setValue(localDrug.quantity, forKey: "quantity")
          drug.setValue(localDrug.date, forKey: "date")
          
          do {
              try managedContext.save()
          } catch let error as NSError {
              print("Erreur lors de l'enregistrement du médicament : \(error), \(error.userInfo)")
          }
      }
    
    // Récupère tous les médicaments de la base de données CoreData
    func fetchDrugsFromDatabase() -> [LocalDrug] {
        var drugs = [LocalDrug]()
        
        let managedContext = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Drug")
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedDrugs = try managedContext.fetch(fetchRequest)
            
            for fetchedDrug in fetchedDrugs {
                if let name = fetchedDrug.value(forKey: "name") as? String,
                   let dose = fetchedDrug.value(forKey: "dose") as? String,
                   let time = fetchedDrug.value(forKey: "time") as? String,
                   let quantity = fetchedDrug.value(forKey: "quantity") as? String,
                   let date = fetchedDrug.value(forKey: "date") as? Date {
                    
                    let localDrug = LocalDrug(name: name, dose: dose, time: time, quantity: quantity, date: date)
                    drugs.append(localDrug)
                }
            }
        } catch let error as NSError {
            print("Erreur lors de la récupération des médicaments : \(error), \(error.userInfo)")
        }
        
        return drugs
    }

    
    // Supprime un médicament de la base de données CoreData
    func deleteDrugFromDatabase(localDrug: LocalDrug) {
        let managedContext = coreDataStack.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Drug")
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND dose == %@ AND time == %@ AND quantity == %@ AND date == %@", localDrug.name, localDrug.dose, localDrug.time, localDrug.quantity, localDrug.date as NSDate)

        do {
            let fetchedDrugs = try managedContext.fetch(fetchRequest)

            for fetchedDrug in fetchedDrugs {
                managedContext.delete(fetchedDrug)
            }

            try managedContext.save()
        } catch let error as NSError {
            print("Erreur lors de la suppression du médicament : \(error), \(error.userInfo)")
        }
    }
}
