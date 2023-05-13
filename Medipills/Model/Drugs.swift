//
//  Drugs.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 10/04/2023.
//

import Foundation

// MARK: - Welcome
struct Drugs: Codable {
    let productNdc, genericName, labelerName, brandName: String
    let activeIngredients: [ActiveIngredient]
    let finished: Bool
    let listingExpirationDate: String?
    let marketingCategory, dosageForm, splID, productType: String
    let route: [String]
    let marketingStartDate, productID, applicationNumber, brandNameBase: String
    let pharmClass: [String]

    enum CodingKeys: String, CodingKey {
        case productNdc = "product_ndc"
        case genericName = "generic_name"
        case labelerName = "labeler_name"
        case brandName = "brand_name"
        case activeIngredients = "active_ingredients"
        case finished, listingExpirationDate
        case marketingCategory = "marketing_category"
        case dosageForm = "dosage_form"
        case splID = "spl_id"
        case productType = "product_type"
        case route
        case marketingStartDate = "marketing_start_date"
        case productID = "product_id"
        case applicationNumber = "application_number"
        case brandNameBase = "brand_name_base"
        case pharmClass = "pharm_class"
    }
}

struct ActiveIngredient: Codable {
    let name, strength: String
}









