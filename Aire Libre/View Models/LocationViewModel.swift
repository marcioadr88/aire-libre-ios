//
//  LocationViewModel.swift
//  Aire Libre
//
//  Created by Marcio Duarte on 2023-05-01.
//

import SwiftUI
import CoreLocation
import MapKit
import OSLog

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let log = Logger(subsystem: "location.re.airelib.ios",
                             category: String(describing: LocationViewModel.self))
    
    @Published var location: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        location = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.error("Could not get location: \(error.localizedDescription)")
    }
    
    func startUpdatingLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            location = nil
        }
    }
}
