//
//  APIManager.swift
//  OpenWeatherTB
//
//  Created by Shehab Saqib on 19/09/2017.
//  Copyright © 2017 Shehab Saqib. All rights reserved.
//

import Foundation

class APIManager {
    
    let apiID = "5f0b929633992e1d801fbc758870d386"
    
    func getWeatherData (lat: Double, lon: Double) -> URL? {
        
        let urlString = String("http://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiID)")
        
        guard let url = URL(string: urlString!) else {
            print("Error: Couldn't create URL from string")
            return nil
        }
        
        return url
        
    }
    
    func performSearch (lat: Double, lon: Double, completion: @escaping (Data?) -> ()) {
        
        let url = getWeatherData(lat: lat, lon: lon)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error getting weather data: \(error)")
                completion(data)
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Error occurred")
                return
            }
            
            completion(data)
    }
        task.resume()
    
}
    
    func downloadWeatherIcon(iconID:String, completion:@escaping (Data?)->()) {
        
        let url:URL = URL(string: "http://openweathermap.org/img/w/\(iconID).png")!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error == nil {
                guard let data = data else {
                    print("Error: No image data found")
                    return
                    }
                completion(data)
                }
            }
        
        task.resume()
}
}
