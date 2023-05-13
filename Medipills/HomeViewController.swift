//
//  ViewController.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 11/01/2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var medicineBrand: UILabel!
    @IBOutlet private weak var brand: UILabel!
    @IBOutlet private weak var searchField: UITextField!
    @IBOutlet private weak var searchBtn: UIButton!
    @IBOutlet private weak var addButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        displayCurrentDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func searchMedicine(_ sender: UIButton) {
        guard let searchText = searchField.text, !searchText.isEmpty else { return }
            
        DrugsService.shared.getDrugInfo(drugName: searchText) { [weak self] result in
                switch result {
                case .success(let drugInfo):
                    if let drug = drugInfo.first {
                        DispatchQueue.main.async {
                            self?.medicineBrand.text = drug.genericName
                            self?.brand.text = drug.activeIngredients.first?.strength
                        }
                    } 
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.statusError(status: error, result: result)
                    }
                }
            }
    }
    
    func statusError(status: ErrorAPI, result: Result<[Drugs], ErrorAPI>) {
           switch result {
           case .success(let drugs):
               if !drugs.isEmpty {
                   // Handle success case
               } else {
                   self.noResultsFound()
               }
           case .failure(let error):
               self.alertServerAccess(error: error.description)
           }
       }
    
    func displayCurrentDate() {
        let currentDate = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let dateString = formatter.string(from: currentDate)
        dateLabel?.text = "Aujourd'hui : " + dateString
        dateLabel?.font = UIFont(name: "Comfortaa-Bold", size: 25.0)
    }


}

