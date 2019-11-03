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
    
    // MARK: Attributs
    let dataBase = Firestore.firestore()
    var missionId: String = ""
    
    // MARK: Outlets
    @IBOutlet weak var reportTextView: UITextView!
    
    
    // MARK: cycle de vie
    override func viewDidLoad() {
        super.viewDidLoad()

        loadReportFromDb()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Modification du bouton dans la barre de navigation
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard))
    }
    
    // Appelé quand la vue va disparaître, mais les données sont encore en mémoire.
    override func viewWillDisappear(_ animated: Bool) {
        let missionRef = dataBase.collection("missions").document(missionId)

        // Mise à jour du rapport dans la BD
        missionRef.updateData([
            "rapport": reportTextView.text ?? ""
        ]) { err in
            if let err = err {
                print("⛔️ Erreur lors de l'écriture du rapport dans la BD : \(err)")
            } else {
                print("✅ Le rapport a bien été mis à jour.")
            }
        }
    }
    
    
    // MARK: private functions
    
    // Récupération du rapport lié à la mission courrante dans la base de données
    private func loadReportFromDb(){
        if missionId != "" {
            let missionRef = dataBase.collection("missions").document(missionId) // Notre référence au document correspondant à la mission courante
            
            missionRef.getDocument { (document, error) in
                if let document = document, document.exists { // Le document a été trouvé
                    print("✅ Le document lié à cette mission a été récupéré correctement.")
                    // On va testé si il existe déjà un rapport pour cette mission. Si c'est le cas, on l'affiche.
                    if let rapport = document.get("rapport") as! String?  {
                        self.reportTextView.text = rapport
                    } else {
                        self.reportTextView.text = "Aucun rapport n'a été enregistré." // Aucun rapport enregistré pour cette mission
                    }
                    
                } else {
                    print("⛔️ Le document demandé n'existe pas !")
                }
            }
        } else {
            print("⛔️ L'identifiant de la mission courante est inconnu !")
        }
    }
    
    // MARK: Actions
    
    // Fonction permettant de cacher le clavier
    @objc func hideKeyboard() {
        reportTextView.resignFirstResponder()
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
