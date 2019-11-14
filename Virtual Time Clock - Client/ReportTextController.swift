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
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard))
        
        // On sauvegarde le texte pour vérifier plus tard si il y a eu des modifications.
        texteInitial = reportTextView.text
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
    }
    
    
    
    // MARK: private functions
    
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
