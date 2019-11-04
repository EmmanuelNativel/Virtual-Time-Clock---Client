//
//  MissionController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/31/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseFirestore

class MissionController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var missionImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lieuLabel: UILabel!
    @IBOutlet weak var pointerImage: UIImageView!
    @IBOutlet weak var pointerButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    
    
    // MARK: Attributs
    var mission: Mission? = nil // La mission courante
    let locationManager = CLLocationManager()
    let database = Firestore.firestore()
    let userID: String = "userIdTest2" // PROVISOIRE
    
    

    // MARK: Cycle de vie
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" ✅ Ouverture de la mission \(mission?.titre ?? "INCONNUE" )")
        
        titleLabel.text = mission?.titre
        descriptionLabel.text = mission?.description
        lieuLabel.text = mission?.lieu
        
        setupImages()   // Personnalisation des images
        setupButtons()  // Personnalisation des boutons
        
        if ( CLLocationManager.locationServicesEnabled() ){                 // On test si la géolocalisation est acitivée
            locationManager.delegate = self                                 // Lien avec le delegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest       // Précision de la géolocalisation
            locationManager.allowsBackgroundLocationUpdates = true          // On autorise la géolocalisation en tache de fond
            locationManager.pausesLocationUpdatesAutomatically = true       // La géolocalisation peut se mettre en pause quand elle n'est pas nécessaire
            locationManager.activityType = .other                           // On indique le type d'utilisation de la géolocalisation
            locationManager.requestAlwaysAuthorization()                    // On demande l'autorisation de géolocaliser à l'utilisateur
        }
    }
    
    
    
    // MARK: Private functions
    
    // Personnalisation des images
    private func setupImages(){
        // Background de l'entête
        missionImage.layer.backgroundColor = UIColor.white.withAlphaComponent(0.4).cgColor  // On change la couleur de fond
        missionImage.layer.borderWidth = 2                          // On donne une bordure
        missionImage.layer.borderColor = UIColor.white.cgColor      // ... de couleur noire
        missionImage.layer.cornerRadius = 45                        // On arrondit les bords
        missionImage.clipsToBounds = true                           // On indique que l'image doit prendre la dorme de la bordure
        
        //Image de pointage
        pointerImage.layer.borderWidth = 2                          // On donne une bordure
        pointerImage.layer.borderColor = UIColor.black.cgColor      // ... de couleur noire
        pointerImage.layer.cornerRadius = 45                        // On arrondit les bords
        pointerImage.clipsToBounds = true                           // On indique que l'image doit prendre la dorme de la bordure
    }
    
    // Personnalisation des boutons
    private func setupButtons(){
        
        // Button de pointage
        // On arrondi le bouton pour qu'il ai la même forme que l'image
        pointerButton.layer.cornerRadius = 45
        // On cache son image
        pointerButton.alpha = 0.1
        pointerButton.tintColor = UIColor.blue
        
        // Bouton pour écrire le rapport
        reportButton.layer.cornerRadius = 20
        reportButton.clipsToBounds = true
        reportButton.layer.borderWidth = 1
        reportButton.layer.borderColor = UIColor.white.cgColor
    }
    
    // Fonction permettant d'animer le bouton de pointage
    private func checkButton(){
        // Couleur de l'image
        pointerButton.tintColor = UIColor.green
        
        // Fade In : On affiche l'image
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.pointerButton.alpha = 0.8
        }, completion: nil)
        
        // Fade Out : On recache l'image
        UIView.animate(withDuration: 0.1, delay: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.pointerButton.alpha = 0.1
            self.pointerButton.tintColor = UIColor.blue
        }, completion: nil)
    }
    
    // Fonction permettant d'observer les entrées et sorties de l'employé dans la zone de la mission courrante
    private func startNotifyLocation(){
        // Récupération des informations nécessaires pour la mise en place de zone de proximité
        let latitude = mission!.latitude
        let longitude = mission!.longitude
        let rayon = 20.0
        
        // Récupération de la position courante de l'employé
        let currentPosition = locationManager.location
        let currentLatitude = currentPosition?.coordinate.latitude
        let currentLongitude = currentPosition?.coordinate.longitude
        
        // Définition de la zone de porximité
        let missionArea = CLCircularRegion(center: CLLocationCoordinate2DMake(latitude, longitude), radius: rayon, identifier: "missionArea")
        
        // On check si l'employé est dans la zone de la mission au moment où il pointe
        if missionArea.contains(CLLocationCoordinate2DMake(currentLatitude!, currentLongitude!)) {
            print("🧭✅ L'employé a pointé. ")
            notifyEnterToDB() // On notifie la base de données que l'employé est dans dans la zone de mission
        } else {
            print("🧭⛔️ L'employé a pointé, mais il n'est pas sur les lieux de la mission ! ")
        }
        
        // On commence à écouter les entrées et sorties de la zone
        locationManager.startMonitoring(for: missionArea)
    }
    
    // Fonction qui enregistre la sortie de l'employé de la zone de la mission courrante dans la base de données
    private func notifyExitToDB(){
        print("ℹ️ Notification de sortie envoyée à la BD")
        database.collection("pointage").document(mission!.id).collection("pointageMission").document(userID).setData(
            [
                "date" : Timestamp(date: Date()), // On enregistre également la date courante
                "estPresent" : false
            ]
        )
    }
    
    // Fonction qui enregistre l'entrée de l'employé dans la zone de la mission courrante dans la base de données
    private func notifyEnterToDB(){
        print("ℹ️ Notification d'entrée envoyée à la BD")
        database.collection("pointage").document(mission!.id).collection("pointageMission").document(userID).setData(
            [
                "date" : Timestamp(date: Date()), // On enregistre également la date courante
                "estPresent" : true
            ]
        )
    }
    
    
    
    // MARK: Actions
    @IBAction func onClickPointerButton(_ sender: UIButton) {
        // Animation du bouton
        checkButton()
        
        // On lance la détection de la position de l'employé
        startNotifyLocation()
    }
    
    
    
    // MARK: - Navigation
    
    //Fonction appelée avant l'envoi d'un segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MissionToReport" {
            
            // Récupération de la destination de notre segue, ici, c'est un UITabBarController.
            let destination = segue.destination as! UITabBarController
            
            // Récupération de la première vue de notre UITabBarController : c'est notre ReportTextController
            let reportTextController = destination.viewControllers![0] as! ReportTextController
            
            // Récupération de la seconde vue de notre UITabBarController : c'est notre ReportImageController
            let reportImageController = destination.viewControllers![1] as! ReportImageController
            
            // On envoit l'id de la mission courante à la vue suivante
            let missionID = mission?.id
            reportTextController.missionId = missionID ?? ""
            reportImageController.missionId = missionID ?? ""
        }
    }
    

} // Fin de la classe MissionController



// MARK: Extensions

extension MissionController: CLLocationManagerDelegate {
    
    // Fonction appellée quand on commence à détecter les entrées et sorties dans la zone de la mission
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("🧭 Lancement du contrôle de présence")
    }
    
    // Fonction appellée quand l'employé entre dans la zone de la mission
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("🧭 Entrée dans la zone")
        
        // Mise à jour du pointage dans la base de données
        notifyEnterToDB()
    }
    
    // Fonction appellée quand l'employé sort de la zone de la mission
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("🧭 Sortie de la zone")
        
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
    
}
