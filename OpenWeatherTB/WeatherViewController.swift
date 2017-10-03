//
//  WeatherViewController.swift
//  OpenWeatherTB
//
//  Created by Shehab Saqib on 19/09/2017.
//  Copyright © 2017 Shehab Saqib. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI
import AVFoundation

fileprivate let reuseIdentifier = "WeatherCell"

class WeatherViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var nameButton: UIBarButtonItem!

    var name = ""

    var weatherData = [Weather]()
    var talker = AVSpeechSynthesizer()
    
    let client = APIManager()
    let parser = WeatherDataParser()
    let kelvin = 273.15
    
    var locationManager: CLLocationManager?
    var startLocation: CLLocation?
    var userLocation = CLLocation()
    
    let spacing: CGFloat = 8.0
    let lineSpacing: CGFloat = 8.0
    let inset: CGFloat = 25.0
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(WeatherViewController.handleRefresh(_:)) , for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    @IBAction func getName(_ sender: UIBarButtonItem) {
        
        alertDialog()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView.addSubview(self.refreshControl)
        startLocationManager()
        if nameButton.title == "" {
            alertDialog()
        }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let name = UserDefaults.standard.object(forKey: "name") as? String {
            nameButton.title = name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func alertDialog() {
        
        let alert = UIAlertController(title: "May we know your name please?", message: "", preferredStyle: .alert)
        
        var nameField:UITextField?
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            nameField = alert.textFields?[0]
            UserDefaults.standard.set(nameField?.text, forKey: "name")
            if let nameF = UserDefaults.standard.object(forKey: "name") as? String {
                self.nameButton.title = nameF
            } else {
                self.nameButton.title = "Name?"
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .default) { (action) in
            
        }
        
        alert.addTextField { (nameField) in
            nameField.placeholder = "John"
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.collectionView.reloadData()
        refreshControl.endRefreshing()
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
extension WeatherViewController: CLLocationManagerDelegate {
    
    func startLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        if #available(iOS 9.0, *) {
            locationManager?.requestLocation()
        } else {
            // Fallback on earlier versions
        }
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if startLocation == nil {
            startLocation = locations.first
        } else {
            //guard let latest = locations.first else { return }
            
            let coordinates = manager.location?.coordinate
            let lat = coordinates!.latitude
            let lon = coordinates!.longitude
            
            let location = CLLocation(latitude: lat, longitude: lon)
            var cityName = ""
            
            
            getCity(location: location) { (city) in
                self.navigationItem.title = "\(city)"
                cityName = city
            }
            
            client.performSearch(lat: lat, lon: lon) { [unowned self] data in
                
                if let wData = self.parser.weatherDataFromSearch(data) {
                    self.weatherData = wData
                }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            print("lat = \(lat) &&&& long = \(lon)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if #available(iOS 9.0, *) {
                locationManager?.requestLocation()
            } else {
                locationManager?.startUpdatingLocation()
            }
        }
        
        if status == .denied || status == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
    }
    
    func getCity(location: CLLocation, completion: @escaping (String) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error)
            } else if let city = placemarks?.first?.locality {
                completion(city)
            }
            
        }
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
extension WeatherViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return weatherData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WeatherCell
    
        // Configure the cell
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: cell.frame.size.height-1, width: cell.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        
        let description = weatherData[indexPath.item].description
        let tempValue = weatherData[indexPath.item].temp - kelvin
        let tempMinValue = weatherData[indexPath.item].tempMin - kelvin
        let tempMaxValue = weatherData[indexPath.item].tempMax - kelvin
        let iconID = weatherData[indexPath.item].iconID
        let dateTime = weatherData[indexPath.item].dateTime
        
        let tempValues = String(format: "%.1f", tempValue)
        let tempMinValues = String(format: "%.1f", tempMinValue)
        let tempMaxValues = String(format: "%.1f", tempMaxValue)
        
        let dateTimeString =  dateString(fromString: dateTime)
        let date = dateTimeString[0]
        let time = dateTimeString[1]
        
        cell.descriptionLabel.text = description
        cell.tempLabel.text = "\(tempValues) ℃"
        cell.tempMinLabel.text = "\(tempMinValues) ℃"
        cell.tempMaxLabel.text = "\(tempMaxValues) ℃"
        cell.dateLabel.text = date
        cell.timeLabel.text = time
    
        client.downloadWeatherIcon(iconID: iconID, completion: { (data) in
            DispatchQueue.main.async {
                cell.iconImageView.image = UIImage(data: data!)
            }
        })
        
        return cell
    }
    
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////
extension WeatherViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell \(indexPath.item)")
        
        let description = weatherData[indexPath.item].description
        let tempValue = weatherData[indexPath.item].temp - kelvin
        let tempMinValue = weatherData[indexPath.item].tempMin - kelvin
        let tempMaxValue = weatherData[indexPath.item].tempMax - kelvin
        let dateTime = weatherData[indexPath.item].dateTime
        
        let tempValues = String(format: "%.1f", tempValue)
        let tempMinValues = String(format: "%.1f", tempMinValue)
        let tempMaxValues = String(format: "%.1f", tempMaxValue)
        
        let dateTimeString =  dateString(fromString: dateTime)
        let date = dateTimeString[0]
        let time = dateTimeString[1]
        
        let utter = AVSpeechUtterance(string: "The weather on \(date) at \(time) is \(description) with the temperature being \(tempValues) degrees celcius. With a high of \(tempMaxValues) degrees celcius and a low of \(tempMinValues) degree celcius.")
        
        let voice = AVSpeechSynthesisVoice(language: "en-GB")
        utter.voice = voice
        
        self.talker.delegate = self
        self.talker.speak(utter)
        
        /////////////////////////////////////////////////////////////////////////////////////////////////
        
        let alert = UIAlertController(title: "Would you like to mail this information?", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.sendMail(description: description, temp: tempValues, tempMin: tempMinValues, tempMax: tempMaxValues, date: date, time: time)
            
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .default) { (action) in
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////
extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Int((collectionView.frame.width - (inset + spacing)))
        let height = 100
    
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
extension WeatherViewController: MFMailComposeViewControllerDelegate {
    func sendMail(description: String, temp: String, tempMin: String, tempMax: String, date: String, time: String) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["abc@example.com"])
            mail.setMessageBody("Hello, the weather on \(date) at \(time) will be \(description). The expected temperature is set at \(temp)℃, with a high of \(tempMax)℃ and a low of \(tempMin)℃. Thank You", isHTML: true)
            
            present(mail, animated: true)
        } else {
            showMessageFailSendAlert()
        }
        
    }
    
    func showMessageFailSendAlert() {
        let alert = UIAlertController(title: "Message Failed To Send",
                                      message: "There seems to be an issue sending the message.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
extension WeatherViewController {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Started")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Finished")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let s = (utterance.speechString as NSString).substring(with: characterRange)
        print("about to say \(s)")
    }
}



