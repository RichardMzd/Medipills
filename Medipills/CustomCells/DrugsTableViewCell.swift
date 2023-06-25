//
//  DrugsTableViewCell.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 19/05/2023.
//

import UIKit

class DrugsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var drugName: UILabel!
    @IBOutlet private weak var dosage: UILabel!
    @IBOutlet private weak var time: UILabel!
    @IBOutlet private weak var pillsOrSpoon: UILabel!
    @IBOutlet private weak var drugIcon: UIImageView!
    
    var segmentTitle: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with drugName: String, isPill: Bool) {
        self.drugName.text = drugName
        
        if isPill {
            drugIcon.image = UIImage(named: "medicament")
        } else {
            drugIcon.image = UIImage(named: "sirop")
        }
    }

    var dosageText: String? {
        didSet {
            dosage.text = dosageText
        }
    }
    
    var timeText: String? {
        didSet {
            time.text = timeText
        }
    }
    
    var pillsOrSpoonText: String? {
        didSet {
            if let text = pillsOrSpoonText {
                let replacedText = text.replacingOccurrences(of: "Cp", with: "Comprimé")
                    .replacingOccurrences(of: "Csp", with: "Cuillère à soupe")
                pillsOrSpoon.text = replacedText
            } else {
                pillsOrSpoon.text = nil
            }
        }
    }
}
