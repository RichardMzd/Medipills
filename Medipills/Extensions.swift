//
//  Extensions.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 01/05/2023.
//

import Foundation
import UIKit
import Lottie
import UserNotifications

extension AddDrugViewController {
    // Method to detect error in API Call request
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
    
    func displayDateTime() {
        let calendar = Calendar.current
        var currentDate = Date()
        
        // Récupérer les composants de l'heure actuelle
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        
        // Arrondir les minutes vers le haut à l'intervalle de 5 minutes suivant
        let roundedMinutes = Int(ceil(Double(currentMinute) / 5.0) * 5.0)
        currentDate = calendar.date(bySettingHour: currentHour, minute: roundedMinutes, second: 0, of: currentDate) ?? currentDate
        
        // Formatter pour l'affichage de la date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "fr_FR")
        
        // Formatter pour l'affichage de l'heure
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let dateString = dateFormatter.string(from: currentDate)
        let timeString = timeFormatter.string(from: currentDate)
        
        dateLabel.text = dateString
        timeLabel.text = timeString
    }
    
    func scheduleNotification(date: Date, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Medipills"
        content.body = message
        content.sound = .default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "notificationIdentifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }

}

extension HomeViewController {
    func setupCoreData() {
        guard coreDataManager == nil,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let coreDataStack = appDelegate.coreDataStack
        coreDataManager = CoreDataManager(coreDataStack: coreDataStack)
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Notifications cancelled.")
    }
    
    func setAnimation() {
        DispatchQueue.main.asyncAfter(deadline:  .now()) {
            self.lottieAnimation.animation = LottieAnimation.named("completing-tasks")
            self.lottieAnimation.contentMode = .scaleAspectFit
            self.lottieAnimation.loopMode = .loop
            self.lottieAnimation.play(completion: nil)
        }
    }
}
