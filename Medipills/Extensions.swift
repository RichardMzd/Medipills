//
//  Extensions.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 01/05/2023.
//

import Foundation
import UIKit

extension HomeViewController {
    //method to detect error in API Call request
       func alertServerAccess(error: String) {
           let alert = UIAlertController(title: "Erreur", message: error, preferredStyle: .alert)
           let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
           alert.addAction(ok)
           self.present(alert, animated: true, completion: nil)
       }
    
    func noResultsFound() {
        let alert = UIAlertController(title: "Aucun résultat trouvé", message: "Veuillez réessayer avec des termes différents", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
