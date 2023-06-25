//
//  AddDrugViewController.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 05/05/2023.
//

import Foundation
import UIKit
import Lottie
import UserNotifications

protocol AddDrugDelegate: AnyObject {
    func didAddDrug(drug: String, dosageText: String?, timeText: String?, pillsOrSpoonText: String?, date: Date?, isPill: Bool?)
}

class AddDrugViewController: UIViewController {
    
//  MARK: - Outlets
    @IBOutlet private weak var mainAnimation: LottieAnimationView!
    @IBOutlet private weak var drugAnimation: LottieAnimationView!
    @IBOutlet private weak var brandTextField: UITextField!
    @IBOutlet private weak var dosageTextfield: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var segmentRoute: UISegmentedControl!
    @IBOutlet weak var buttonsStackView: UIStackView! // outlet for the stack view
    
    
    // MARK: - Properties
    private var counter = 0
    private var dosageText: String?
    private var timeText: String?
    private var pillsOrSpoonText: String?
    private var timer: Timer?

    var selectedDate: Date?
    
    let myDatePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    weak var delegate: AddDrugDelegate?
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(named: "blueMed")
        setupUI()
        updateLottie(segment: segmentRoute)
        displayDateTime()
        startTimer()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupUI()
        updateLottie(segment: segmentRoute)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }

    
    // MARK: - Actions
    @IBAction func updateCounter(_ sender: UIButton) {
        if sender.tag == 0 {
            incrementCounter()
        } else {
            decrementCounter()
        }
    }
    
    @IBAction func addDrug(_ sender: Any) {
        showMessageIfNoInfo()
            DrugsService.shared.getValueFromLocalJSON(medic: brandTextField.text!) { [weak self] result in
                switch result {
                case .success:
                    if self?.selectedDate == nil {
                        // If no date is selected, use the date currently displayed in dateLabel
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.dateFormat = "d MMM yyyy"
                        formatter.locale = Locale(identifier: "fr_FR")
                        if let dateString = self?.dateLabel.text, let date = formatter.date(from: dateString) {
                            self?.selectedDate = date
                        }
                    }
                    
                    self?.delegate?.didAddDrug(drug: self?.brandTextField.text ?? "",
                                               dosageText: self?.dosageTextfield.text,
                                               timeText: self?.timeLabel.text,
                                               pillsOrSpoonText: self?.counterLabel.text,
                                               date: self?.selectedDate,
                                               isPill: self?.segmentRoute.selectedSegmentIndex == 0)
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.statusError(status: error, result: result)
                    }
                }
            }
    }
    
    
    @IBAction func chooseDateTime(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
           
           let formatter = DateFormatter()
           formatter.locale = Locale(identifier: "fr_FR")

           if sender.tag == 1 { // Date button
               myDatePicker.datePickerMode = .date
               alert.title = "Choisir la date"
               formatter.dateStyle = .medium
               myDatePicker.locale = Locale(identifier: "fr_FR")

               alert.view.addSubview(myDatePicker)
               myDatePicker.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   myDatePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                   myDatePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40)
               ])
           } else if sender.tag == 2 { // Time button
               timePicker.datePickerMode = .time
               alert.title = "Choisissez l'heure"
               timePicker.minuteInterval = 5
               
               alert.view.addSubview(timePicker)
               timePicker.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   timePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                   timePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40)
               ])
               
               formatter.dateFormat = "HH:mm"
           }
           
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
               if sender.tag == 1 {
                   let selectedDate = self.myDatePicker.date
                   self.dateLabel.text = formatter.string(from: selectedDate)
//                   self.scheduleNotification(date: selectedDate, message: "Rappel ⏰: Vous avez des médicaments à prendre 💊")
               } else if sender.tag == 2 {
                   let selectedTime = self.timePicker.date
                   let selectedTimeFormatted = formatter.string(from: selectedTime)
                   
                   self.timeLabel.text = selectedTimeFormatted
                   self.scheduleNotification(date: selectedTime, message: "Rappel ⏰: Vous avez des médicaments à prendre 💊")
               }
           }))
           
           present(alert, animated: true)
    }
    
    
    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setDrugAnimation(lottieName: "blue_pill")
            resetCounter()
        case 1:
            setDrugAnimation(lottieName: "syrup")
            counterLabel.text = "\(counter) csp"
            resetCounter()
        default:
            break
        }
    }
    
    // MARK: - Methods
    
    private func showMessage(_ message: String) {
        // Affichez le message d'erreur à l'utilisateur, par exemple :
        let alertController = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showMessageIfNoInfo() {
        
        let fields: [(textField: UITextField, message: String)] = [
            (textField: brandTextField, message: "marque"),
            (textField: dosageTextfield, message: "dosage")
        ]

        for field in fields {
            guard let text = field.textField.text, !text.isEmpty else {
                showMessage("Veuillez remplir le champ \(field.message).")
                return
            }
        }
        
        guard let counterText = counterLabel.text, !counterText.isEmpty else { return }

        if counterText == "0 Cp" || counterText == "0 Csp" {
            showMessage("La valeur du champ counter doit être supérieure à zéro.")
            return
        }
    }
    
    func statusError(status: ErrorAPI, result: Result<Bool, ErrorAPI>) {
        switch result {
        case .failure(let error):
            self.alertServerAccess(error: error.localizedDescription)
        default:
            break
        }
    }
    
    
    private func setupUI() {
        setAnimation(lottie: mainAnimation, name: "medicine")
        counterLabel.text = String(counter)
        
        for button in buttonsStackView.subviews where button is UIButton {
            button.layer.cornerRadius = button.frame.width / 2
            button.clipsToBounds = true
        }
    }
    
    private func incrementCounter() {
        counter += 1
        
        if segmentRoute.selectedSegmentIndex == 1 {
            counterLabel.text = "\(counter) Csp"
        } else {
            counterLabel.text = "\(counter) Cp"
        }
    }
    
    private func decrementCounter() {
        if counter > 0 {
            counter -= 1
            
            if segmentRoute.selectedSegmentIndex == 1 {
                counterLabel.text = "\(counter) Csp"
            } else {
                counterLabel.text = "\(counter) Cp"
            }
        }
    }
    
    private func resetCounter() {
        counter = 0
        if segmentRoute.selectedSegmentIndex == 1 {
            counterLabel.text = "\(counter) Csp"
        } else {
            counterLabel.text = "\(counter) Cp"
        }
    }
    
    private func updateLottie(segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            setDrugAnimation(lottieName: "blue_pill")
            counterLabel.text = "\(counter) Cp"
        case 1:
            setDrugAnimation(lottieName: "syrup")
            counterLabel.text = "\(counter) Csp"
        default:
            break
        }
    }
    
    private func setAnimation(lottie: LottieAnimationView, name: String) {
        DispatchQueue.main.asyncAfter(deadline:  .now()) {
            lottie.animation = LottieAnimation.named(name)
            lottie.contentMode = .scaleAspectFit
            lottie.loopMode = .loop
            lottie.play(completion: nil)
        }
    }
    
    private func setDrugAnimation(lottieName: String) {
        setAnimation(lottie: drugAnimation, name: lottieName)
    }
    
    private func startTimer() {
        // Arrêter la minuterie existante si elle est en cours
        stopTimer()
        
        // Démarrer une minuterie qui se déclenche toutes les secondes
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.displayDateTime()
        }
        
        // Mettre à jour immédiatement l'affichage de l'heure
        displayDateTime()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

