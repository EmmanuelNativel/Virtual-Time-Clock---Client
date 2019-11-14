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
import FirebaseAuth

class MissionController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var missionImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lieuLabel: UILabel!
    @IBOutlet weak var pointerImage: UIImageView!
    @IBOutlet weak var pointerButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var checkLabel: UILabel!
    
    
    
    // MARK: Attributs
    let locationManager = CLLocationManager()   // Gestionnaire de géolocalisation
    let database = Firestore.firestore()        // Référence à notre base de données
    var mission: Mission? = nil                 // La mission courante
    var rapport: Rapport?                       // Le rapport de la mission courrante
    let user = Auth.auth().currentUser          // L'utilisateur courant
    var userID: String?                         // Id de l'utilisateur courant
    
    

    // MARK: Cycle de vie
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Si aucun utilisateur n'est connecté, on affiche la vue de connexion
        if user == nil {
            print("⛔️ Aucun utilisateur n'est connecté ! Redirection à l'écran de login.")
            self.performSegue(withIdentifier: "backToLoginController", sender: self)
        }
        
        print(" ✅ Ouverture de la mission \(mission?.titre ?? "INCONNUE" )")
        
        setupLabels()   // Préparation des Labels
        setupImages()   // Personnalisation des images
        setupButtons()  // Personnalisation des boutons
        
        userID = user?.uid ?? ""
        
        if ( CLLocationManager.locationServicesEnabled() ){                 // On test si la géolocalisation est acitivée
            locationManager.delegate = self                                 // Lien avec le delegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest       // Précision de la géolocalisation
            locationManager.allowsBackgroundLocationUpdates = true          // On autorise la géolocalisation en tache de fond
            locationManager.pausesLocationUpdatesAutomatically = true       // La géolocalisation peut se mettre en pause quand elle n'est pas nécessaire
            locationManager.activityType = .other                           // On indique le type d'utilisation de la géolocalisation
            locationManager.requestAlwaysAuthorization()                    // On demande l'autorisation de géolocaliser à l'utilisateur
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // On récupère le rapport dans la base de données
        if mission?.id != nil {
            getReportFromDB(forMissionId: mission!.id)
        }
    }
    
    
    
    // MARK: Private functions
    
    // Préparation des Labels
    private func setupLabels(){
        titleLabel.text = mission?.titre
        descriptionLabel.text = mission?.description
        lieuLabel.text = mission?.lieu
        checkLabel.text = NSLocalizedString("check", comment: "Mission")
    }
    
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
        
        // Bouton pour écrire le rapport
        reportButton.layer.cornerRadius = 20
        reportButton.clipsToBounds = true
        reportButton.layer.borderWidth = 1
        reportButton.layer.borderColor = UIColor.white.cgColor
        reportButton.setTitle(NSLocalizedString("reportButton", comment: "Mission"), for: .normal)
    }
    
    // Fonction permettant d'animer le bouton de pointage
    private func checkButton(valide: Bool){
        // Couleur de l'image
        let color = valide ? UIColor.green : UIColor.red
        
        // Type d'image (on utilise des images du système iOS)
        let image = valide ? UIImage.init(systemName: "checkmark.seal") : UIImage.init(systemName: "xmark.seal")

        pointerButton.setBackgroundImage(image, for: UIControl.State.normal)
        pointerButton.tintColor = color
        
        // Fade In : On affiche l'image
        UIView.animate(withDuration: 1, delay: 0.3, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.pointerButton.alpha = 0.8
        }, completion: nil)
        
        // Fade Out : On cache l'image
        UIView.animate(withDuration: 1, delay: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.pointerButton.alpha = 0.1
        }) { (animationIsOver) in
            self.pointerButton.tintColor = nil // On termine par enlever la couleur de l'image
        }
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
            // On lance l'animation du bouton
            checkButton(valide: true)
            // On notifie la base de données que l'employé est dans dans la zone de mission
            notifyEnterToDB()
            // On commence à écouter les entrées et sorties de la zone
            locationManager.startMonitoring(for: missionArea)
        } else {
            print("🧭⛔️ L'employé n'est pas sur les lieux de la mission ! ")
            // On lance l'animation du bouton
            checkButton(valide: false)
        }
    }
    
    // Fonction qui enregistre la sortie de l'employé de la zone de la mission courrante dans la base de données
    private func notifyExitToDB(){
        if userID != "" {
            print("ℹ️ Notification de sortie envoyée à la BD")
            database.collection("pointage").document(mission!.id).collection("pointageMission").document(userID!).setData(
                [
                    "date" : Timestamp(date: Date()), // On enregistre également la date courante
                    "estPresent" : false
                ]
            )
        }
    }
    
    // Fonction qui enregistre l'entrée de l'employé dans la zone de la mission courrante dans la base de données
    private func notifyEnterToDB(){
        if userID != "" {
            print("ℹ️ Notification d'entrée envoyée à la BD")
            database.collection("pointage").document(mission!.id).collection("pointageMission").document(userID!).setData(
                [
                    "date" : Timestamp(date: Date()), // On enregistre également la date courante
                    "estPresent" : true
                ]
            )
        }
    }
    
    // Fonction permettant de récupérer le rapport de la mission courante dans la BD. Effet de bord : variable rapport
    private func getReportFromDB(forMissionId: String) {
        let missionID = mission?.id ?? ""
        
        if missionID != "" {
            let missionsRef = database.collection("missions").document(missionID)
            
            missionsRef.getDocument { (document, error) in
                // On test si le document lié à cette mission existe bien
                if let document = document, document.exists {
                    // On récupère le rapport stocké dans le document. C'est un dictionnaire.
                    let rapportFromDB: [String: Any]? = document.get("rapport") as? [String: Any]
                    
                    if rapportFromDB != nil { // Si un rapport existe sur la base de données,
                        // On va récupérer les données de ce rapport :
                        let timestamp: Timestamp = rapportFromDB!["date"] as! Timestamp         // Récupération de la date
                        let date: Date = timestamp.dateValue()                                  // Conversion de la date
                        let texte: String = rapportFromDB!["texte"] as! String                  // Récupération du texte
                        let imagePath: String = rapportFromDB!["imageUrl"] as? String ?? ""     // Récupération de l'url de l'image
                        
                        self.rapport =  Rapport(texte: texte, imagePath: imagePath, date: date) // On récupère ce rapport sous forme d'objet Rapport()
                    } else { print("ℹ️ Il n'existe pas de rapport pour cette mission.") }
                }
                else { print("⛔️ Erreur : Le document demandé pour cette mission n'existe pas !") }
            }
        }
    }
    
    
    
    // MARK: Actions
    @IBAction func onClickPointerButton(_ sender: UIButton) {
        // On lance la détection de la position de l'employé
        startNotifyLocation()
    }
    
    
    // MARK: - Navigation
    
    //Fonction appelée avant l'envoi d'un segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MissionToReport" {
            
            // Récupération de la destination de notre segue, ici, c'est un UITabBarController.
            let destination = segue.destination as! UITabBarController
            
            // Récupération de la première vue de notre UITabBarController : c'est notre ReportTextController (affichage du texte et date du rapport)
            let reportTextController = destination.viewControllers![0] as! ReportTextController
            
            // Récupération de la seconde vue de notre UITabBarController : c'est notre ReportImageController (affichage de l'image du rapport)
            let reportImageController = destination.viewControllers![1] as! ReportImageController
            
            let missionID = mission?.id ?? ""
            
            if missionID != "" {
                // On envoi l'id de la mission courante aux vues suivantes
                reportTextController.missionId = missionID
                reportImageController.missionId = missionID
                
                // On va envoyer la même instance de rapport aux 2 vues, pour qu'elles gardent les mêmes données.
                if rapport != nil {
                    // Si le rapport a été trouvé dans la base de données, on l'envoi aux 2 vues.
                    reportTextController.rapport = rapport
                    reportImageController.rapport = rapport
                } else {
                    // Sinon, on crée un rapport vide, et on l'envoi aux 2 vues.
                    let rapportVide = Rapport()
                    reportTextController.rapport = rapportVide
                    reportImageController.rapport = rapportVide
                }
            } else {
                print("⛔️ L'ID de la mission n'a pas pu être récupéré !")
            }
        }
        // Segue de retour vers la page de login. (Appelé lors de l'appui sur le bouton de déconnexion)
        else if segue.identifier == "backToLoginController" {
            // On déconnecte l'utilisateur courrant
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
              print ("Erreur lors de la déconnexion : \(signOutError)")
            }
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
