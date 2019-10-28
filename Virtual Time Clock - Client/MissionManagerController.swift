//
//  MissionManagerController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/28/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit
import FirebaseAuth

class MissionManagerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //Récupération de l'utilisateur connecté
        if let user = Auth.auth().currentUser {
            //User connected
            //user.email
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
