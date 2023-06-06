//
//  ViewController.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 11/01/2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var drugTableView: UITableView!
    @IBOutlet private weak var labeltext: UILabel!
    
    let numberOfDates = 30 // Nombre total de dates à afficher
    var selectedCellIndex: Int?
    var drugsInfoArray: [LocalDrug]?
    
    var brandText: String?
    var dosageText: String?
    var dateText: String?
    var counterText: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        drugTableView.delegate = self
        drugTableView.dataSource = self
        
        drugsInfoArray = [LocalDrug]()
        setupCell()
        
        // Définir la direction de défilement horizontal
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            //              flowLayout.minimumInteritemSpacing = 10 // Espacement horizontal entre les cellules
        }
        collectionView.reloadData()
        drugTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addDrugViewController = segue.destination as? AddDrugViewController {
            addDrugViewController.delegate = self
        }
    }
    
    func setupCell() {
        let nibName = UINib(nibName: "DrugsTableViewCell", bundle: nil)
        drugTableView.register(nibName, forCellReuseIdentifier: "drugCell")
    }
    
    //  select date cell of CollectionView
    func selectCell(at index: Int) {
        selectedCellIndex = index
        collectionView.reloadData()
    }
}

// MARK: - TableView settings

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let drugArray = drugsInfoArray else { return 0 }
        return drugArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let drugCell = tableView.dequeueReusableCell(withIdentifier: "drugCell", for: indexPath) as? DrugsTableViewCell else {
            return UITableViewCell()
        }
        
        guard let drugsArray = drugsInfoArray else { return UITableViewCell() }
        
        let drug = drugsArray[indexPath.row]
        drugCell.configure(with: drug.name)
        drugCell.dosageText = drug.dose
        drugCell.timeText = drug.time
        drugCell.pillsOrSpoonText = drug.quantity
        
        if drugsArray.isEmpty {
                   labeltext.isHidden = false // Afficher le label lorsque la tableView est vide
                   drugTableView.isHidden = true // Cacher la tableView lorsque vide
               } else {
                   labeltext.isHidden = true // Cacher le label lorsque la tableView contient des éléments
                   drugTableView.isHidden = false // Afficher la tableView lorsque non vide
               }
        
        return drugCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Supprimer la cellule et mettre à jour votre modèle de données
            guard var drugsArray = drugsInfoArray else { return }
            drugsArray.remove(at: indexPath.row)
            drugsInfoArray = drugsArray
            
            // Supprimer la cellule de la tableView
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if drugsArray.isEmpty {
                       labeltext.isHidden = false // Afficher le label lorsque la tableView est vide
                       drugTableView.isHidden = true // Cacher la tableView lorsque vide
                   } else {
                       labeltext.isHidden = true // Cacher le label lorsque la tableView contient des éléments
                       drugTableView.isHidden = false // Afficher la tableView lorsque non vide
                   }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(140)
    }
}

// MARK: - CollectionView settings

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfDates
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCollectionViewCell
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = indexPath.item // Ajoutez un jour à chaque index
        
        if let date = calendar.date(byAdding: dateComponents, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E\ndd"
            let dateString = dateFormatter.string(from: date)
            cell.dateLabel.text = dateString
        }
        
        if let selectedCellIndex = selectedCellIndex, indexPath.item == selectedCellIndex {
            cell.backgroundColor = UIColor(named: "Color")
        } else {
            cell.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.height // Utilisez la hauteur de la collectionView pour définir la largeur de la cellule
        let height: CGFloat = selectedCellIndex == indexPath.item ? 50 : 50 // Hauteur souhaitée pour la cellule sélectionnée et les autres cellules
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCell(at: indexPath.item)
    }
    
}

// MARK: - Delegate

extension HomeViewController: AddDrugDelegate {
    func didAddDrug(drug: String, dosageText: String?, timeText: String?, pillsOrSpoonText: String?) {
        guard let dosageText = dosageText,
              let timeText = timeText,
              let pillsOrSpoonText = pillsOrSpoonText else {
            return
        }
        
        let drug = LocalDrug(name: drug, dose: dosageText, time: timeText, quantity: pillsOrSpoonText)
        self.drugsInfoArray?.append(drug)
        drugTableView.reloadData()
    }
}

