//
//  AddDrugViewController.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 05/05/2023.
//

import Foundation
import UIKit
import Lottie

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
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(named: "blueMed")
        setupUI()
        updateLottie(segment: segmentRoute)
        
//        // Configure the date picker
//        myDatePicker.datePickerMode = .date
//        myDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        
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
            let alert = UIAlertController(title: "Choose a date", message: nil, preferredStyle: .alert)
            alert.view.addSubview(myDatePicker)
            myDatePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                myDatePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40),
                myDatePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            ])
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                // Update the selected date label with the date selected in the date picker
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                self.dateLabel.text = formatter.string(from: self.myDatePicker.date)
            }))
            present(alert, animated: true)
        }

    @objc func dateChanged() {
        print(myDatePicker.date)

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

