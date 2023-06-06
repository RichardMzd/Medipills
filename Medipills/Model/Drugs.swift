//
//  Drugs.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 10/04/2023.
//

import Foundation

// MARK: - Drugs

struct Drugs: Codable {
    let cip13: Int
    let nomCourt: String?
    
    enum CodingKeys: String, CodingKey {
        case cip13 = "CIP13"
        case nomCourt = "NOM COURT"
    }
}

struct LocalDrug {
    var name: String
    var dose: String
    var time: String
    var quantity: String
}
