//
//  DateCollectionViewCell.swift
//  Medipills
//
//  Created by Richard Arif Mazid on 18/05/2023.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!

        override func awakeFromNib() {
            super.awakeFromNib()
            dateLabel.font = UIFont(name: "Comfortaa-regular", size: 20)
            dateLabel.textColor = UIColor(named: "blueMed")
        }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = UIColor.clear
    }

}
