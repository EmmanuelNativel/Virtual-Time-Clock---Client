//
//  ReportImageController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 11/2/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseUI

class ReportImageController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var missionImageView: UIImageView!
    
    
    // MARK: Attributs
    let dataBase = Firestore.firestore()    // Référence de notre base de données
    let storage = Storage.storage()         // Référence de notre espace de stockage sur le serveur
    var missionId: String = ""              // ID de la mission courante
    var rapport: Rapport?                   // Rapport de la mission courante
    
    
    
    // MARK: Cycle de vie 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Chargement de l'image depuis l'espace de stockage
        if rapport != nil {
            loadImageFromStorage(path: rapport!.imagePath)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Modification du bouton dans la barre de navigation
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCamera))
    }
    
    
    
    // MARK: private functions
    
    // Fonction permettant d'upload l'image vers l'espace de stockage du serveur
    private func uploadImageToStorage(image:UIImage){
        // Image en mémoire sous forme de Data
        let imageData = image.pngData()
        
        // Url de l'image sur le serveur
        let url = "missionsRapportsImages/\(missionId).png"

        // Création de la référence du l'image
        let imagesFoldRef = storage.reference().child(url)
        
        // Upload de l'image
        let uploadImageTask = imagesFoldRef.putData(imageData!, metadata: nil)
        
        // On écoute quand l'upload est terminé
        uploadImageTask.observe(.success) { snapshot in
            print("✅ L'image a correctement été téléchargée par le serveur.")
            
            self.writeImagePathInBd(url: url)   // On met à jour l'url de l'image dans la base de données
        }
        
        // On écoute les erreurs
        uploadImageTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                print("⛔️ Erreur lors de l'upload de l'image : \(error.description)")
            }
        }
    }
    
    // Fonction permettant de mettre à jour le path de l'image, stockée dans le storage, dans la base de données
    private func writeImagePathInBd(url: String){
        // Notre référence au document correspondant à la mission courante
        let missionRef = dataBase.collection("missions").document(missionId)
        
        // Mise à jour de l'objer rapport
        rapport!.imagePath = url
        
        // Mise à jour de l'image dans la BD
        missionRef.updateData([
            "rapport": [
                "texte" : rapport!.texte,
                "imageUrl" : rapport!.imagePath,
                "date" : rapport!.date
            ]
        ]) { err in
            if let err = err { print("⛔️ Erreur lors de l'écriture du chemin de l'image dans la BD : \(err)") }
            else { print("✅ L'url de l'image du rapport a bien été mis à jour dans la BD.") }
        }
    }
    
    // Chargement de l'image du rapport depuis l'espace de stockage du serveur
    private func loadImageFromStorage(path: String){
        // Lecture dans l'espace de stockage du serveur
        if path != "" {
            let imageRef = self.storage.reference().child(path)  // Référence de notre image
            
            // On va tester si l'image correspondant au path existe sur le serveur en regardant si ses métadonnées ne sont pas nulles.
            imageRef.getMetadata { (metadata, error) in
                if let error = error {
                    // L'image n'existe pas dans le storage
                    print("⛔️ Impossible d'accéder aux métadonnées de l'image : \(error)")
                } else {
                    // Les métadonnées sont présentes, donc l'image existe bel et bien dans le storage
                    // On va insérer l'image dans l'ImageView prévue à cet effet.
                    self.missionImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(contentsOfFile: "notFound")) { (image, error, cache, storageRef) in
                        if let error = error { print("⛔️ L'image n'a pas pu être chargée ! : \(error)") }
                        else { print("✅ L'image a été mise à jour avec succès. ") }
                    }
                }
            }
        } else { print("ℹ️ Il n'y a pas d'image associé à ce rapport.") }
    }
    
    
    
    
    // MARK: Actions
    
    // Fonction appelée lors du clique sur le bouton caméra
    @objc func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) { // On vérifie si le téléphone a un appareil photo
            let imagePicker = UIImagePickerController() // On va utiliser le logiciel de capture fourni par iOS
            imagePicker.delegate = self
            imagePicker.sourceType = .camera // On indique qu'on aura uniquement besoin de la caméra
            imagePicker.allowsEditing = true // On autorise l'édition de l'image
            self.present(imagePicker, animated: true, completion: nil) // On affiche la vue
        }
    }
    
} // Fin de la classe ReportImageController



// MARK: Extensions

// Les héritages de UIImagePickerControllerDelegate et UINavigationControllerDelegate sont nécessaires pour utiliser l'appareil photo

extension ReportImageController: UIImagePickerControllerDelegate {
    
    // Fonction appelée quand l'utilisateur a validé l'image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {     // Récupération de l'image
            missionImageView.image = image                  // Remplissage de l'ImageView avec l'image prose par l'utilisateur
            
            // On va maintenant upload l'image dans le storage sur le serveur
            if missionId != "" {
                uploadImageToStorage(image: image)
            } else { print("⛔️ L'image n'a pas été upload car l'identifiant de la mission courante est inconnu !") }
        }
        picker.dismiss(animated: true, completion: nil) // On fait disparaître la vue
    }
    
    // Fonction appelée quand l'utilisateur annule la prise de photo
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) // On fait disparaître la vue
    }
    
}


extension ReportImageController: UINavigationControllerDelegate{
    
}
