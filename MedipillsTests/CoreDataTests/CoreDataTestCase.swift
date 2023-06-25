//
//  MedipillsTests.swift
//  MedipillsTests
//
//  Created by Richard Arif Mazid on 14/06/2023.
//

import XCTest
@testable import Medipills


final class CoreDataTestCase: XCTestCase {

    var coreDataManager: CoreDataManager!
        
        override func setUpWithError() throws {
            try super.setUpWithError()
            // Initialization of CoreDataManager with MockCoreDataStack
            let coreDataStack = MockCoreDataStack()
            coreDataManager = CoreDataManager(coreDataStack: coreDataStack)
        }
        
        override func tearDownWithError() throws {
            coreDataManager = nil
            try super.tearDownWithError()
        }
        
        func testSaveDrugToDatabase() {
            // Create a test LocalDrug object
            let localDrug = LocalDrug(name: "Drug", dose: "10mg", time: "14:30", quantity: "1", date: Date(), isPill: Bool())
            
            // Call the method saveDrugToDatabase
            coreDataManager.saveDrugToDatabase(localDrug: localDrug)
            
            // Getting the medicines from database
            let drugs = coreDataManager.fetchDrugsFromDatabase()
            
            // Check if the registered drug is present in the list of retrieved drugs
            XCTAssertTrue(drugs.contains(localDrug))
        }
        
        func testDeleteDrugFromDatabase() {
            // Create a test LocalDrug object
            let localDrug = LocalDrug(name: "Drug", dose: "10mg", time: "14:30", quantity: "1", date: Date(), isPill: Bool())
            
            // Register the drug in the database
            coreDataManager.saveDrugToDatabase(localDrug: localDrug)
            
            // Delete the drug from the database
            coreDataManager.deleteDrugFromDatabase(localDrug: localDrug)
            
            // Retrieve drugs from the database
            let drugs = coreDataManager.fetchDrugsFromDatabase()
            
            // Check if the deleted drug is no longer present in the list of retrieved drugs
            XCTAssertFalse(drugs.contains(localDrug))
        }

}
