//
//  MissionManagerController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/30/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class MissionManagerController: UITableViewController {
    
    // MARK: Attributs
    
    let db = Firestore.firestore()
    var missions: [Mission] = []
    //var missions: [Mission] = [Mission(titre: "titre1", lieu: "lieu1", description: "description1"), Mission(titre: "titre2", lieu: "lieu2", description: "description2"), Mission(titre: "titre3", lieu: "lieu3", description: "description3")]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Si aucun utilisateur est connecté, on crash l'application
        if Auth.auth().currentUser == nil {
            fatalError("⛔️ Aucun utilisateur n'est connecté !")
        } else { // Sinon, on affiche les missions
            loadMissionsFromDB(dataBase: db)
        }
    }
    
    
    // MARK: Private functions
    
    private func loadMissionsFromDB(dataBase: Firestore){
        // Lecture des documents dans la collection "missions"
        dataBase.collection("missions").getDocuments() { (query, err) in
            if let err = err {
                print("⛔️ Erreur : Impossible d'obtenir les missions ! \(err)")
            } else {
                print("✅ Document récupéré !")
                for document in query!.documents {
                    
                    // Pour chaque document, on crée une mission et on l'ajoute à la liste
                    
                    //Récupération des String
                    let id: String = document.documentID
                    let titre: String = document.get("titre") as! String
                    let description: String = document.get("description") as! String
                    let lieu: String = document.get("lieu") as! String
                    
                    // Récupération des dates
                    let debut_timestamp: Timestamp = document.get("debut") as! Timestamp
                    let debut: Date = debut_timestamp.dateValue()
                    let fin_timestamp: Timestamp = document.get("fin") as! Timestamp
                    let fin: Date = fin_timestamp.dateValue()
                    
                    // Récupération des positions (géolocalisation)
                    let localisation: GeoPoint = document.get("localisation") as! GeoPoint
                    let latitude = localisation.latitude
                    let longitude = localisation.longitude
                    
                    // Récupération de Number (rayon)
                    let rayon: Int = document.get("rayon") as! Int
            
                    
                    // Création de la mission et ajout dans la liste
                    self.missions.append( Mission(id: id, titre: titre, lieu: lieu, description: description, debut: debut, fin: fin, latitude: latitude, longitude: longitude, rayon: rayon) )
                    
                }
                
                self.tableView.reloadData() // Rechargmement des données des cellules
                print("✅ Les missions sont correctement affichées !")
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missions.count
    }

    // Configuration d'une cellule
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Création de notre cellule personnalisée
        let cell = tableView.dequeueReusableCell(withIdentifier: "missionCell") as! MissionCell
        
        // Récupération de la mission courante dans la liste
        let mission = missions[indexPath.row]
        
        // On rempli les différents champs de notre cellule avec la mission courante
        cell.populate(mission: mission)
        

        return cell
    }
    
    
    // MARK: - Navigation

    // Fontion permettant de faire des actions avant l'envoi du segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Récupération de la destination du segue
        let destination = segue.destination as! MissionController
        
        // On test si le segue est bien celui qu'on espère
        if segue.identifier == "MissionsManagerToMission" {
            // On récupère l'index de la cellule sélectionnée
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let mission = missions[indexPath.row]   // On récupère la mission correspondante
                destination.mission = mission           // On transfert la mission à la vue suivante
            }
        }
    }
    
    
    /*
    //Clique sur une cellule
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Récupération de la mission correspondant à la cellule cliquée
        //let mission = missions[indexPath.row]
        
        //performSegue(withIdentifier: "MissionsManagerToMission", sender: self)
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
