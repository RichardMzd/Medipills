//
//  DrugService.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 10/04/2023.
//

import Foundation

class DrugsService {
    
    static let shared = DrugsService()
    
    private init() {}
    
    func getValueFromLocalJSON(medic: String, completion: @escaping (Result<Bool, ErrorAPI>) -> Void) {
        guard let url = Bundle.main.url(forResource: "medic", withExtension: "json") else {
            completion(.failure(ErrorAPI.jsonFileNotFound))
            return
        }
        do {
            let jsonData = try Data(contentsOf: url)
            let drugs = try JSONDecoder().decode([Drugs].self, from: jsonData)
            
            let result = drugs.first(where: { drug in
                if let nomCourt = drug.nomCourt {
                    return nomCourt.lowercased().contains(medic.lowercased())
                }
                return false
            })
            
            if let _ = result {
                completion(.success(true))
                return
            } else {
                completion(.failure(.decoding))
            }
        } catch {
            completion(.failure(.decoding))
        }
    }
}


