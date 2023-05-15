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

class AddDrugViewController: UIViewController {
    
    @IBOutlet private weak var mainAnimation: LottieAnimationView!
    @IBOutlet private weak var drugAnimation: LottieAnimationView!
    @IBOutlet private weak var brandTextField: UITextField!
    @IBOutlet private weak var dosageTextfield: UITextField!
    @IBOutlet private weak var dateButton: UIButton!
    @IBOutlet private weak var timeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var segmentRoute: UISegmentedControl!
    @IBOutlet weak var buttonsStackView: UIStackView! // outlet for the stack view
    
    
    // MARK: - Properties
    private var counter = 0
    let myDatePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(named: "blueMed")
        setupUI()
        updateLottie(segment: segmentRoute)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupUI()
        updateLottie(segment: segmentRoute)
    }
    
    // MARK: - Actions
    @IBAction func updateCounter(_ sender: UIButton) {
        if sender.tag == 0 {
            incrementCounter()
        } else {
            decrementCounter()
        }
    }
    
    //  MARK: - Actions
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            if sender.tag == 1 { // Date button
                myDatePicker.datePickerMode = .date
                alert.title = "Choose date"
                
                alert.view.addSubview(myDatePicker)
                myDatePicker.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    myDatePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40),
                    myDatePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                ])
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    let selectedDate = self.myDatePicker.date
                    self.dateLabel.text = formatter.string(from: selectedDate)
                    
                    self.scheduleNotification(date: selectedDate, message: "You have some medicine to take")
                }))
            } else if sender.tag == 2 { // Time button
                timePicker.datePickerMode = .time
                alert.title = "Choose time"
                
                alert.view.addSubview(timePicker)
                timePicker.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    timePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40),
                    timePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                ])
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm a"
                    let selectedTime = self.timePicker.date
                    let selectedTimeFormatted = formatter.string(from: selectedTime)
                    
                    self.timeLabel.text = selectedTimeFormatted
                    self.scheduleNotification(date: selectedTime, message: "You have some medicine to take")
                }))
            }
            
            present(alert, animated: true)
    }

    
    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setDrugAnimation(lottieName: "blue_pill")
            resetCounter()
        case 1:
            setDrugAnimation(lottieName: "syrup")
            counterLabel.text = "\(counter) tsp"
            resetCounter()
        default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    func scheduleNotification(date: Date, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Medipills"
        content.body = message
        content.sound = .default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: combinedComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "notificationIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
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
            counterLabel.text = "\(counter) tsp"
        } else {
            counterLabel.text = "\(counter)"
        }
    }
    
    private func decrementCounter() {
        if counter > 0 {
            counter -= 1
            
            if segmentRoute.selectedSegmentIndex == 1 {
                counterLabel.text = "\(counter) tsp"
            } else {
                counterLabel.text = "\(counter)"
            }
        }
    }
    
    private func resetCounter() {
        counter = 0
        if segmentRoute.selectedSegmentIndex == 1 {
            counterLabel.text = "\(counter) tsp"
        } else {
            counterLabel.text = "\(counter)"
        }
    }
    
    private func updateLottie(segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            setDrugAnimation(lottieName: "blue_pill")
            counterLabel.text = "\(counter)"
        case 1:
            setDrugAnimation(lottieName: "syrup")
            counterLabel.text = "\(counter) tsp"
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
    
}

