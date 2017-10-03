//
//  WeatherCollectionViewCell.swift
//  OpenWeatherTB
//
//  Created by Shehab Saqib on 19/09/2017.
//  Copyright © 2017 Shehab Saqib. All rights reserved.
//

import UIKit

class WeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        //self.layer.borderWidth = 1
        //self.layer.borderColor = UIColor.black.cgColor
    }
    
}
