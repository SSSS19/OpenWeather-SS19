//
//  mapViewController.swift
//  OpenWeatherTB
//
//  Created by Shehab Saqib on 20/09/2017.
//  Copyright © 2017 Shehab Saqib. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func segMapControl(_ sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
    }
    
    var weatherData = [Weather]()
    var locationManager: CLLocationManager?
    let client = APIManager()
    let parser = WeatherDataParser()
    
    let regionRadius: CLLocationDistance = 500
    let kelvin = 273.15
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //startLocationManager()
        mapView.showsUserLocation = true
       
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        searchBar.resignFirstResponder()
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let localSearch = MKLocalSearch(request: searchRequest)
        
        localSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                print("error")
            } else {
                
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                print("\(latitude!) + \(longitude!)")
                
                self.client.performSearch(lat: latitude!, lon: longitude!) { data in
                    
                    if let wData = self.parser.weatherDataFromSearch(data) {
                        self.weatherData = wData
                        
                        print("\(self.weatherData.count) wData")
                    }
                }
                
                print("\(self.weatherData.count) = Weather Data")
                let descriptions = self.weatherData.first?.description
                let temp = self.weatherData.first?.temp
                guard descriptions != nil else {
                    return
                }
                
                guard temp != nil else {
                    return
                }
                
                let tempV = temp! - self.kelvin
                let tempC = String(format: "%.1f", tempV)
                
                let annotation = MKPointAnnotation()
                annotation.title = "\(searchBar.text!) - \(descriptions!) - \(tempC)℃"
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
                let coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegionMake(coord, span)
                self.mapView.setRegion(region, animated: true)
                
            }
        }
    }
}
/*
    enum activityIndicatorStatus {
        case show
        case hide
    }

    func showOrHideActivityIndicator(cases: activityIndicatorStatus) -> UIView? {
        
        switch cases {
        
        case .show:
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            
            return activityIndicator
        
        case .hide:
            let activityIndicators = UIActivityIndicatorView()
            activityIndicators.stopAnimating()
            return nil
        }
        
    } */
    
