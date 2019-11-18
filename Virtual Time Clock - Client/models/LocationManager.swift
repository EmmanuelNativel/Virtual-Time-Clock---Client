//
//  LocationManager.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 11/16/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager{
    
    static let shared = LocationManager()
    
    let manager: CLLocationManager
    var locationGranted: Bool?
    var areas : [String:CLCircularRegion] = [:]
    
    private init(){
        manager = CLLocationManager()
    }
    
    func requestForLocation(){
        //Code Process
        locationGranted = true
        print("Location granted")
    }
    
    // Ajout d'une zone dans la liste des zones. L'id de la zone doit être l'id de la mission
    func addArea(areaId: String, latitude: Double, longitude: Double, rayon: Double){
        
        let missionArea = CLCircularRegion(center: CLLocationCoordinate2DMake(latitude, longitude), radius: rayon, identifier: areaId)
        
        areas[areaId] = missionArea
    }
    
    // Démarrage du pointage automatique dans la zone associée
    func startPointageListening(areaId: String) -> Bool {
        let area: CLCircularRegion = areas[areaId]!
        let currentPosition = manager.location?.coordinate
        
        if area.contains(currentPosition!) {
            manager.startMonitoring(for: area)
            return true
        } else {
            return false
        }
    }
    
    func stopPointageListening(areaId: String) {
        manager.stopMonitoring(for: areas[areaId]!)
    }
    
}
