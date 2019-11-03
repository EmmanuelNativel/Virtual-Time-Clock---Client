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
    let dataBase = Firestore.firestore()
    let storage = Storage.storage()
    var missionId: String = ""

    
    
    // MARK: Cycle de vie 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Chargement de l'image
        if missionId != "" {
            loadReportImageFromStorage()
        } else { print("⛔️ Impossible de charger l'image car l'identifiant de la mission courante est inconnu !") }
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
            
            self.writeImagePathInBd(url: url)
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
        
        // Mise à jour de l'image dans la BD
        missionRef.updateData([
            "rapportImageRef": url
        ]) { err in
            if let err = err { print("⛔️ Erreur lors de l'écriture du chemin de l'image dans la BD : \(err)") }
            else { print("✅ L'imagePath du rapport a bien été mis à jour dans la BD.") }
        }
    }
    
    // Fonction permettant de charger l'image de la mission courante dans l'imageView prévue à cet effet
    private func loadReportImageFromStorage(){
            // Notre référence au document correspondant à la mission courante
            let missionRef = dataBase.collection("missions").document(missionId)
            
            missionRef.getDocument { (document, error) in
                if let document = document, document.exists { // Le document a été trouvé
                    print("✅ Le document lié à cette mission a été récupéré correctement.")
                    // On va tester s'il existe déjà une image pour cette mission. Si c'est le cas, on l'affiche.
                    if let imagePath = document.get("rapportImageRef") as! String?  {
                        print("✅ Le chemin d'accès à l'image a été trouvé dans la BD : \(imagePath)")
                        
                        // Lecture dans l'espace de stockage du serveur
                        let imageRef = self.storage.reference().child(imagePath)  // Référence de notre image
                        
                        // On va tester si l'image correspondant au path existe sur le serveur en regardant si ses métadonnées ne sont pas nulles.
                        imageRef.getMetadata { (metadata, error) in
                            if let error = error {
                                // L'image n'existe pas dans le storage
                                print("⛔️ Impossible d'accéder aux métadonnées de l'image : \(error)")
                            } else {
                                // Les métadonnées sont présentes, donc l'image existe bel et bien dans le storage
                                self.missionImageView.sd_setImage(with: imageRef, placeholderImage: UIImage(contentsOfFile: "notFound")) { (image, error, cache, storageRef) in
                                    if let error = error { print("⛔️ L'image n'a pas pu être chargée ! : \(error)") }
                                    else { print("✅ L'image a été mise à jour avec succès. ") }
                                }
                            }
                        }
                        
                    } else { print("ℹ️ Il n'y a pas d'image associée au rapport de cette mission.") }
                } else { print("⛔️ Le document demandé n'existe pas !") }
            }
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
