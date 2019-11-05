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
    @IBOutlet weak var dateLabel: UILabel!
    
    
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
            dateLabel.text = rapport!.date.description
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Modification du bouton dans la barre de navigation
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard))
        
        // On sauvegarde le texte pour vérifier plus tard si il y a eu des modifications.
        texteInitial = reportTextView.text
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
    
    
    
    // MARK: Actions
    
    // Fonction permettant de cacher le clavier
    @objc func hideKeyboard() {
        reportTextView.resignFirstResponder()
    }

}
