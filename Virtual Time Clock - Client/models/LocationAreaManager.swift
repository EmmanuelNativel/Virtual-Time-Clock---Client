//
//  LocationAreaManager.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 11/21/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class LocationAreaManager: NSObject{
    
    static let shared = LocationAreaManager()
    
    let manager = CLLocationManager()       // location Manager global à l'applciation
    let database = Firestore.firestore()    // base de données
    var currentArea: CLCircularRegion?      // Zone de proximité à "monitorer"
    var userID: String = ""                 // id user
    var mission: Mission?                   // mission courrante
    var currentPosition: CLLocation?        // position courante
    
    override init(){
        super.init()
        manager.delegate = self                                     // Lien avec le delegate
        manager.desiredAccuracy = kCLLocationAccuracyBest           // Précision de la géolocalisation
        manager.allowsBackgroundLocationUpdates = true              // On autorise la géolocalisation en tache de fond
        manager.pausesLocationUpdatesAutomatically = true           // La géolocalisation peut se mettre en pause
        manager.activityType = .other                               // On indique le type d'utilisation de la géolocalisation
    }
    
    
    // Lancement du monitoring pour la zone en paramètre
    func startMonitoringForNewArea(newArea:CLCircularRegion){
        // Si il y a déjà une mission en cours de minitoring, on la stop
        if currentArea != nil && userID != "" && mission != nil {
            manager.stopMonitoring(for: currentArea!)
            notifyExitToDB()    // On annonce à la BD que l'employé ne pointe plus sur cette mission
        }
        // On lance le monitoring sur la nouvelle zone
        manager.startMonitoring(for: newArea)
        currentArea = newArea
        print("✅ La zone a été modifiée")
    }
    
    // Paramétrage
    func setupManager(){
        manager.requestAlwaysAuthorization()    // Demande d'autorisation
        manager.startUpdatingLocation()         // Début du relever de pisitions
    }
    
    // Notifier à la base de données que l'employé est sorti de la mission courrante
    private func notifyExitToDB(){
        if userID != "" && mission != nil {
            print("ℹ️ Notification de sortie envoyée à la BD")
            database.collection("pointage").document(mission!.id).collection("pointageMission").document(userID).setData(
                [
                    "date" : Timestamp(date: Date()), // On enregistre également la date courante
                    "estPresent" : false
                ]
            )
        }
    }
    
    // Notifier à la base de données que l'employé est entré dans la mission courrante
    private func notifyEnterToDB(){
           if userID != "" && mission != nil  {
               print("ℹ️ Notification d'entrée envoyée à la BD")
               database.collection("pointage").document(mission!.id).collection("pointageMission").document(userID).setData(
                   [
                       "date" : Timestamp(date: Date()), // On enregistre également la date courante
                       "estPresent" : true
                   ]
               )
           }
    }
    
    // Lancement du pointage automatique, si l'employé est dans la zone
    func isUserInArea(area:CLCircularRegion, userId: String, mission: Mission) -> Bool {
        // On test si l'employé est dans la zone
        if currentPosition != nil && area.contains(CLLocationCoordinate2DMake((currentPosition?.coordinate.latitude)!, (currentPosition?.coordinate.longitude)!)) {
            self.userID = userId    // On indique l'employé actuel
            self.mission = mission  // On indique la mission actuelle
            self.startMonitoringForNewArea(newArea: area)   // On commence le monitoring pour la nouvelle zone
            notifyEnterToDB()   // On notifi la BD que l'employé a pointé
            return true
        } else {
            return false
        }
    }
    
    
    // Arrêter la détection
    func stopLocationUpdate(){
        manager.stopUpdatingLocation()
    }
    
    // A appeler quand on quitte l'application ! Pour stopper complètement
    func stopMonitoring(){
        if currentArea != nil {
            notifyExitToDB()
            manager.stopMonitoring(for: currentArea!)
        }
    }
    
}

extension LocationAreaManager: CLLocationManagerDelegate {
    
    // Fonction appellée quand on commence à détecter les entrées et sorties dans la zone de la mission
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("🧭 Lancement du contrôle de présence")
    }
    
    // Fonction appellée quand l'employé entre dans la zone de la mission
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Mise à jour du pointage dans la base de données
        notifyEnterToDB()
    }
    
    // Fonction appellée quand l'employé sort de la zone de la mission
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Mise à jour du pointage dans la base de données
        notifyExitToDB()
    }
    
    // Détection d'erreur
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("🧭⛔️ Erreur de monitoring : \(error)")
    }
    
    // Check de la permission obtenue
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print(" 🔥 Permission Always obtenue ! ")
        }
        if status == .authorizedWhenInUse {
            print(" 🔥 Permission WhenInUse obtenue ! ")
        }
        if status == .denied {
            print(" 🔥 La permission a été refusée ! ")
        }
        if status == .notDetermined {
            print(" 🔥 La statut de la permission est inconnu ! ")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            currentPosition = lastLocation  // On récupère la position courrante
        }
    }
    
}


