//
//  MissionManagerController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/28/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MissionManagerController: UIViewController {
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        //Récupération de l'utilisateur connecté
        if let user = Auth.auth().currentUser {
            //User connected
            //user.email
            /*
            let userId = user.uid
            db.collection("utilisateurs").document(userId).setData([
                "nom" : "nomTest1",
                "prenom" : "prenomTest1",
                "isLeader" : false,
                "entreprise" : "NirloCorp"
            ]) {
                err in
                if let err = err {
                    print("Erreur")
                } else {
                    print("Document créé")
                }
            }
            */
        } else {
            fatalError("⛔️ Erreur : aucun utilisateur connecté !")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
