//
//  Extension+DateFormatter.swift
//  OpenWeatherTB
//
//  Created by Shehab Saqib on 20/09/2017.
//  Copyright © 2017 Shehab Saqib. All rights reserved.
//

import Foundation

extension WeatherViewController {
    
    func dateString(fromString dateString: String) -> [String] {
        
        var convertedDate = ""
        var convertedTime = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMM d"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH-mm-ss"
        let newTimeFormatter = DateFormatter()
        newTimeFormatter.dateFormat = "h:mm a"
        
        let dateComponents = dateString.components(separatedBy: " ")
        
        let date = dateComponents[0]
        let time = dateComponents[1]
        
        if let dates = dateFormatter.date(from: date) {
            convertedDate = newDateFormatter.string(from: dates)
        }
        
        if let times = timeFormatter.date(from: time) {
            convertedTime = newTimeFormatter.string(from: times)
        }
        
        var dateTime = [String]()
        
        dateTime.append(convertedDate)
        dateTime.append(convertedTime)
        
        return dateTime
        
    }
    
}
