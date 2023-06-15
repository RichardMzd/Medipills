//
//  DrugServiceTestCase.swift
//  MedipillsTests
//
//  Created by Richard Arif Mazid on 14/06/2023.
//

import XCTest
@testable import Medipills

final class DrugServiceTestCase: XCTestCase {

    func testGetValueFromLocalJSON() {
            let expectation = XCTestExpectation(description: "API Call")
            
            // Call the getValueFromLocalJSON method with an existing drug in the JSON file
            DrugsService.shared.getValueFromLocalJSON(medic: "Medic") { result in
                switch result {
                case .success(let value):
                    XCTAssertTrue(value)
                case .failure(_):
                    XCTFail("La valeur devrait être trouvée dans le fichier JSON.")
                }
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
}
