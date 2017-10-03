//
//  WeatherDataParser.swift
//  OpenWeatherTB
//
//  Created by Shehab Saqib on 19/09/2017.
//  Copyright © 2017 Shehab Saqib. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: AnyObject]

class WeatherDataParser {
    
    func parseDictionary(_ data: Data?) -> JSONDictionary? {
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                return json
            }
        } catch {
            print("Couldn't parse JSON. Error: \(error)")
        }
        return nil
    }
    
    func weatherDataFromSearch(_ data: Data?) -> [Weather]? {
        guard let dict = parseDictionary(data) else {
            print("Error: couldn't parse dictionary from data")
            return nil
        }
        
        guard let weatherDicts = dict["list"] as? [JSONDictionary] else {
            print("Error: couldn't parse items from JSON: \(dict)")
            return nil
        }
        
        return weatherDicts.flatMap { parseData($0) }
    }
    
    func parseData(_ dict: JSONDictionary) -> Weather? {
        
        guard let main = dict["main"] as? [String: Any] else {
            print("Error: Couldn't get main")
            return nil
        }
        
        
        guard let weather = dict["weather"] as? NSArray else {
            print("Error: Couldn't get weather")
            return nil
        }
        
       guard let dateTime = dict["dt_txt"] as? String else {
            print("Error: Couldn't get date/time")
            return nil
        }
 
            let temp = main["temp"] as? Double
            let tempMin = main["temp_min"] as? Double
            let tempMax = main["temp_max"] as? Double
        
            let weathers = weather[0] as! NSDictionary
            let description = weathers["description"] as? String
            let iconID = weathers["icon"] as? String
        
        //let dateTime = dict["dt_txt"] as? String
            
        let weatherData = Weather(description: description!, temp: temp!, tempMin: tempMin!, tempMax: tempMax!, iconID: iconID!, dateTime: dateTime)
        
            return weatherData
       /* } else {
            print("Error: couldn't parse JSON dictionary: \(dict)")
        }
        return nil */
    }
    
}
