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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with drugName: String) {
        self.drugName.text = drugName
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
