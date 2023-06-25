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
    
    //  MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var drugTableView: UITableView!
    @IBOutlet private weak var labeltext: UILabel!
    @IBOutlet weak var lottieAnimation: LottieAnimationView!
    
    //  MARK: - Propreties
    
    let numberOfDates = 30 // Nombre total de dates à afficher
    
    var selectedDate: Date?
    var selectedCellIndex: Int?
    var brandText: String?
    var dosageText: String?
    var dateText: String?
    var counterText: String?
    var drugsInfoArray: [LocalDrug]?
    var filteredDrugsArray: [LocalDrug]?
    
    var coreDataManager: CoreDataManager?
    
    //  MARK: - Lifecycle
    
    override func viewDidLoad() {
        setupUI()
        setupCoreData()
        selectTodayCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAnimation()
        drugsInfoArray = coreDataManager?.fetchDrugsFromDatabase()
        updateSelectedDate()
        updateDrugTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addDrugViewController = segue.destination as? AddDrugViewController {
            addDrugViewController.delegate = self
        }
    }
    
    //  MARK: - Methods
    
    private func setupUI() {
        setAnimation()
        collectionView.delegate = self
        collectionView.dataSource = self
        drugTableView.delegate = self
        drugTableView.dataSource = self
        setupCell()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    private func setupCell() {
        let nibName = UINib(nibName: "DrugsTableViewCell", bundle: nil)
        drugTableView.register(nibName, forCellReuseIdentifier: "drugCell")
    }
    
    // Update drug table view with selected date
    private func updateDrugTableView() {
        guard let selectedDate = selectedDate else {
            filteredDrugsArray = drugsInfoArray ?? []
            drugTableView.reloadData()
            return
        }
        
        filteredDrugsArray = drugsInfoArray?.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.time < $1.time }
        
        drugTableView.reloadData()
        tableViewIsEmpty(drugArray: filteredDrugsArray ?? [])
        checkTableViewEmptyState()
    }
    
    // Select today's cell in the collection view when launching the app
    private func selectTodayCell() {
        if let todayIndex = calculateSelectedCellIndex(for: Date()) {
            let indexPath = IndexPath(item: todayIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            selectCell(at: todayIndex)
            collectionView.reloadData()
        }
    }
    
//  Method to display
    private func updateSelectedDate() {
        guard let selectedCellIndex = selectedCellIndex else {
            selectedDate = Date() // Utilise la date actuelle si aucun index de cellule n'est sélectionné
            return
        }
        
        if let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) {
            selectedDate = Calendar.current.date(byAdding: .day, value: selectedCellIndex, to: today)
        }
    }
    
    // Perform actions after deleting a drug
    private func didDeleteDrug() {
        cancelNotifications() // Cancel scheduled notifications
        drugsInfoArray = coreDataManager?.fetchDrugsFromDatabase()
        updateDrugTableView()
    }
    
    // Calculate the index of the selected cell for a given date
    private func calculateSelectedCellIndex(for date: Date) -> Int? {
        let calendar = Calendar.current
        guard let today = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) else {
            return nil
        }
        
        let days = calendar.dateComponents([.day], from: today, to: date).day ?? 0
        
        return days
    }
    
    //  Select date cell of CollectionView
    private func selectCell(at index: Int) {
        selectedCellIndex = index
        collectionView.reloadData()
    }
    
    // Check if the table view is empty and update UI
    private func tableViewIsEmpty(drugArray: [LocalDrug]) {
            lottieAnimation.isHidden = !drugArray.isEmpty
            labeltext.isHidden = !drugArray.isEmpty
            drugTableView.isHidden = drugArray.isEmpty
        }
    
    // Check if the filtered drugs array is empty and update UI
    private func checkTableViewEmptyState() {
            labeltext.isHidden = !(filteredDrugsArray?.isEmpty ?? true)
            lottieAnimation.isHidden = !(filteredDrugsArray?.isEmpty ?? true)
            drugTableView.isHidden = filteredDrugsArray?.isEmpty ?? true
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
        drugCell.configure(with: drug?.name ?? "", isPill: drug?.isPill ?? false)
        drugCell.dosageText = drug?.dose
        drugCell.timeText = drug?.time
        drugCell.pillsOrSpoonText = drug?.quantity
        
        tableViewIsEmpty(drugArray: filteredDrugsArray ?? [])
        
        return drugCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let drugToRemove = filteredDrugsArray?[indexPath.row] else { return }
            
            // Delete the drug from database
            coreDataManager?.deleteDrugFromDatabase(localDrug: drugToRemove)
            
            // Update the arrays
            if let indexInDrugsArray = drugsInfoArray?.firstIndex(of: drugToRemove) {
                drugsInfoArray?.remove(at: indexInDrugsArray)
            }
            
            if let indexInFilteredDrugs = filteredDrugsArray?.firstIndex(of: drugToRemove) {
                filteredDrugsArray?.remove(at: indexInFilteredDrugs)
            }
            
            didDeleteDrug()
            
            // Completely update table view
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
            dateFormatter.locale = Locale(identifier: "fr_FR")
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

// Implement AddDrugDelegate protocol for handling actions from AddDrugViewController
extension HomeViewController: AddDrugDelegate {
    
    // Handle adding a new drug
    func didAddDrug(drug: String, dosageText: String?, timeText: String?, pillsOrSpoonText: String?, date: Date?, isPill: Bool?) {
        guard let dosageText = dosageText,
              let timeText = timeText,
              let pillsOrSpoonText = pillsOrSpoonText,
              let date = date,
              let isPill = isPill else { return }
        
        let newDrug = LocalDrug(name: drug, dose: dosageText, time: timeText, quantity: pillsOrSpoonText, date: date, isPill: isPill)
        
        if drugsInfoArray == nil {
            drugsInfoArray = [newDrug]
        } else {
            drugsInfoArray?.append(newDrug)
            coreDataManager?.saveDrugToDatabase(localDrug: newDrug)
        }
        
        //  permet de postionner la cell sélectionner en fonction d'un nouveau médicament ajouter
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


