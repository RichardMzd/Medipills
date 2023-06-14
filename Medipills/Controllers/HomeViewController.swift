//
//  ViewController.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 11/01/2023.
//

import UIKit
import CoreData
import Lottie

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var drugTableView: UITableView!
    @IBOutlet private weak var labeltext: UILabel!
    @IBOutlet private weak var lottieAnimation: LottieAnimationView!
    
    let numberOfDates = 30 // Nombre total de dates à afficher
    var selectedCellIndex: Int?
    var drugsInfoArray: [LocalDrug]?
    var filteredDrugsArray: [LocalDrug]?
    
    var brandText: String?
    var dosageText: String?
    var dateText: String?
    var counterText: String?
    var selectedDate: Date?
    
    var coreDataManager: CoreDataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAnimation()
        collectionView.delegate = self
        collectionView.dataSource = self
        drugTableView.delegate = self
        drugTableView.dataSource = self
        setupCell()
        // Définir la direction de défilement horizontal
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        setupCoreData()
        selectTodayCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAnimation()
        drugsInfoArray = coreDataManager?.fetchDrugsFromDatabase()
        updateDrugTableView()
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
    
    func tableViewIsEmpty(drugArray: [LocalDrug]) {
        if drugArray.isEmpty {
            lottieAnimation.isHidden = false
            labeltext.isHidden = false // Afficher le label lorsque la tableView est vide
            drugTableView.isHidden = true // Cacher la tableView lorsque vide
        } else {
            labeltext.isHidden = true // Cacher le label lorsque la tableView contient des éléments
            lottieAnimation.isHidden = true
            drugTableView.isHidden = false // Afficher la tableView lorsque non vide
        }
    }
    
    func checkTableViewEmptyState() {
        if filteredDrugsArray?.isEmpty ?? true {
            labeltext.isHidden = false // Afficher le label lorsque la tableView est vide
            lottieAnimation.isHidden = false
            drugTableView.isHidden = true // Cacher la tableView lorsque vide
        } else {
            labeltext.isHidden = true // Cacher le label lorsque la tableView contient des éléments
            lottieAnimation.isHidden = true 
            drugTableView.isHidden = false // Afficher la tableView lorsque non vide
        }
    }
    
    func updateDrugTableView() {
        guard let selectedDate = selectedDate else {
            filteredDrugsArray = drugsInfoArray ?? []
            drugTableView.reloadData()
            return
        }
        
        let filteredDrugs = drugsInfoArray?.filter { drug in
            return Calendar.current.isDate(drug.date, inSameDayAs: selectedDate)
        }
        
        let sortedDrugs = filteredDrugs?.sorted { (drug1, drug2) -> Bool in
            return drug1.time.compare(drug2.time, options: .numeric) == .orderedAscending
        }
        
        filteredDrugsArray = sortedDrugs ?? []
        drugTableView.reloadData()
        tableViewIsEmpty(drugArray: sortedDrugs ?? [])
        checkTableViewEmptyState()
    }

    func calculateSelectedCellIndex(for date: Date) -> Int? {
        let calendar = Calendar.current
        guard let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) else {
            return nil
        }
        
        let days = calendar.dateComponents([.day], from: today, to: date).day ?? 0
        
        return days
    }
    
    func selectTodayCell() {
        if let todayIndex = calculateSelectedCellIndex(for: Date()) {
            let indexPath = IndexPath(item: todayIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            selectCell(at: todayIndex)
            collectionView.reloadData()
            //            updateDrugTableView() // Mettre à jour la liste des médicaments en fonction de la date sélectionnée
        }
    }
    
    private func setupCoreData() {
        guard coreDataManager == nil,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let coreDataStack = appDelegate.coreDataStack
        coreDataManager = CoreDataManager(coreDataStack: coreDataStack)
    }
    
    
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Notifications cancelled.")
    }
    
    func didDeleteDrug() {
        cancelNotifications() // Annuler les notifications programmées
        drugsInfoArray = coreDataManager?.fetchDrugsFromDatabase()
        updateDrugTableView()
    }
    
    private func setAnimation() {
        DispatchQueue.main.asyncAfter(deadline:  .now()) {
            self.lottieAnimation.animation = LottieAnimation.named("completing-tasks")
            self.lottieAnimation.contentMode = .scaleAspectFit
            self.lottieAnimation.loopMode = .loop
            self.lottieAnimation.play(completion: nil)
        }
    }
    
}

// MARK: - TableView settings

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDrugsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let drugCell = tableView.dequeueReusableCell(withIdentifier: "drugCell", for: indexPath) as? DrugsTableViewCell,
              let _ = filteredDrugsArray else {
            return UITableViewCell()
        }
        
        let drug = filteredDrugsArray?[indexPath.row]
        drugCell.configure(with: drug?.name ?? "")
        drugCell.dosageText = drug?.dose
        drugCell.timeText = drug?.time
        drugCell.pillsOrSpoonText = drug?.quantity
        
        tableViewIsEmpty(drugArray: filteredDrugsArray ?? [])
        
        return drugCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let drugToRemove = filteredDrugsArray?[indexPath.row] else { return }
            
            // Supprimer le médicament de la base de données
            coreDataManager?.deleteDrugFromDatabase(localDrug: drugToRemove)
            
            // Mettre à jour les tableaux
            if let indexInDrugsArray = drugsInfoArray?.firstIndex(of: drugToRemove) {
                drugsInfoArray?.remove(at: indexInDrugsArray)
            }
            
            if let indexInFilteredDrugs = filteredDrugsArray?.firstIndex(of: drugToRemove) {
                filteredDrugsArray?.remove(at: indexInFilteredDrugs)
            }
            
            didDeleteDrug()
            
            // Mettre à jour complètement la table view
            updateDrugTableView()
            checkTableViewEmptyState()
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
            dateFormatter.dateFormat = "EE\ndd"
            dateFormatter.locale = Locale(identifier: "fr_FR") // Définir la locale en fr_FR
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
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = indexPath.item
        
        if let date = calendar.date(byAdding: dateComponents, to: Date()) {
            selectedDate = date
            selectCell(at: indexPath.item)
            updateDrugTableView()
        }
    }
    
}

// MARK: - Delegate

extension HomeViewController: AddDrugDelegate {
    func didAddDrug(drug: String, dosageText: String?, timeText: String?, pillsOrSpoonText: String?, date: Date?) {
        guard let dosageText = dosageText,
              let timeText = timeText,
              let pillsOrSpoonText = pillsOrSpoonText,
              let date = date else { return }
        
        let newDrug = LocalDrug(name: drug, dose: dosageText, time: timeText, quantity: pillsOrSpoonText, date: date)
        
        if drugsInfoArray == nil {
            drugsInfoArray = [newDrug]
        } else {
            drugsInfoArray?.append(newDrug)
            coreDataManager?.saveDrugToDatabase(localDrug: newDrug)
        }
        
        //        permet de postionner la cell sélectionner en fonction d'un nouveau médicament ajouter
        if selectedDate == nil || !Calendar.current.isDate(date, inSameDayAs: selectedDate!) {
            selectedDate = date
            if let newIndex = calculateSelectedCellIndex(for: date) {
                selectCell(at: newIndex)
                collectionView.reloadData()
            }
        }
        updateDrugTableView()
    }
}


