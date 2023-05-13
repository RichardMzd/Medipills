//
//  ErrorAPI.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 28/04/2023.
//

import Foundation


//MARK: Error Manager
enum ErrorAPI: Error {
    case decoding
    case server
    case network
    
    var description : String {
        switch self {
        case ErrorAPI.decoding:
            return "Le statut de la réponse a échoué"
            
        case ErrorAPI.network:
            return "Erreur réseau"
            
        case ErrorAPI.server:
            return "L'accès au serveur a échoué"
        }
    }
}
