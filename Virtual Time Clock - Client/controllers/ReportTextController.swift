//
//  ReportTextController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 11/2/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreMotion

class ReportTextController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var dateLabel: UILabel! // Contient la date de la dernière mise à jour du rapport
    
    
    
    // MARK: Attributs
    let dataBase = Firestore.firestore()    // Référence à notre base de données
    var missionId: String = ""              // ID de la mission de courrante
    var rapport: Rapport?                   // Rapport de la mission courante
    var texteInitial: String = ""           // Texte initial du rapport
    let motionManager = CMMotionManager()   // Manageur de capteurs
    var isMovingPhone: Bool = false         // Vrai quand le téléphone est en mouvement
    var lastTimeCheck:Date?                 // Heure de début du dernier mouvement
    
    
    // MARK: cycle de vie
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On affiche le texte et la date du rapport
        if rapport != nil {
            reportTextView.text = rapport!.texte
            dateLabel.text = rapport!.getDateFormat()
            dateText.text = NSLocalizedString("dateLabel", comment: "Mission")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Modification du bouton dans la barre de navigation
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done , target: self, action: #selector(hideKeyboard))
        
        // On sauvegarde le texte pour vérifier plus tard si il y a eu des modifications.
        texteInitial = reportTextView.text
        
        // On va écouter les mouvements de l'accélétomètre avec les données pré-traitées
        listenDeviceMovement()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // On va détecter les geste de swipe vers la gauche
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    // Appelé quand la vue va disparaître, mais les données sont encore en mémoire.
    override func viewWillDisappear(_ animated: Bool) {
        // On met à jour la base de données uniquement si le texte a été modifié.
        if reportTextView.text != texteInitial {
            updateReportOnDB()
        }
        
        motionManager.stopDeviceMotionUpdates() // On désactive le capteur
    }
    
    
    
    
    // MARK: private functions
    
    // Fonction qui utilise l'accéléromètre pour détecter une secousse du téléphone et efface le texte du rapport le téléhpone est secoué pendant plus de 0.5 secondes
    private func listenDeviceMovement(){
        // On va utiliser les données pré-traitées de l'accéléromètre
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1 // Interval de prélèvement des valeurs
            motionManager.startDeviceMotionUpdates(to: .main) { (dm, error) in
                if let e = error {
                    print("⛔️ Erreur lors du relevé des valeurs du DeviceMotion : \(e.localizedDescription)")
                } else {
                    let accelerationX = dm?.userAcceleration.x  // Accélération sur l'axe X
                    let accelerationY = dm?.userAcceleration.y  // Accélération sur l'axe Y
                    let accelerationZ = dm?.userAcceleration.z  // Accélération sur l'axe Z
                    let now = Date() // Date actuelle
                    
                    // Si on détecte une secousse
                    if abs(accelerationX!) > 0.5 || abs(accelerationY!) > 0.5 || abs(accelerationZ!) > 0.5 {
                        if !self.isMovingPhone { // Si le téléphone n'est pas en état "moving"
                            self.lastTimeCheck = now    // On lance le chrono, en sauvegardant l'heure actuelle
                            self.isMovingPhone = true   // On indique que le téléphone est dans l'état "moving"
                        } else if now.timeIntervalSince(self.lastTimeCheck!) >= 0.5 {   // Si le téléphone est dans l'état "moving" pendant plus de 0.5 secondes
                            self.reportTextView.text = ""   // On efface le texte
                            self.isMovingPhone = false      // On indique que le téléphone n'est plus dans l'état "moving"
                        }
                    } else {
                        // Si le téléphone ne bouge plus on indique qu'il n'est plus dans l'état "moving"
                        self.isMovingPhone = false
                    }
                }
            }
        }
    }
    
    // Fonction permettant de mettre à jour le rapport dans la base de données
    private func updateReportOnDB(){
        let missionRef = dataBase.collection("missions").document(missionId)
        
        // Mise à jour de l'objet rapport
        rapport!.date = Date()  // On transmet la date courante
        rapport!.texte = reportTextView.text
        
        // Mise à jour du rapport dans la BD
        missionRef.updateData([
            "rapport": [
                "texte" : rapport!.texte,
                "imageUrl" : rapport!.imagePath,
                "date" : Timestamp(date: rapport!.date)
            ]
        ]) { err in
            if let err = err {
                print("⛔️ Erreur lors de l'écriture du rapport dans la BD : \(err)")
            } else {
                print("✅ Le rapport a bien été mis à jour.")
            }
        }
    }
    
    // Fonction qui permet de changer de vue avec une animation lorsque l'utilisateur fait un swipe vers la gauche
    func pushControllerFromRight(){
        // Création de l'animation de notre transition d'écran
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        // On incrémente la vue du tabBar en utilisant notre animation
        if (self.tabBarController?.selectedIndex)! < 2 {
            self.tabBarController?.selectedIndex += 1
        }
    }
    
    
    
    // MARK: Actions
    
    // Fonction permettant de cacher le clavier
    @objc func hideKeyboard() {
        reportTextView.resignFirstResponder()
    }
    
    // Fonction appelée lorsqu'un swipe est détecté
    @objc func onSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        // On change de vue avec une animation de slide partant de la droite
        if gesture.direction == .left {
            pushControllerFromRight()
        }
    }

}
