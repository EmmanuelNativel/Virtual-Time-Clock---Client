//
//  ImagePickerController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 11/3/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit

class ImagePickerController: UIImagePickerController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

// MARK: Extensions

// Les héritages de UIImagePickerControllerDelegate et UINavigationControllerDelegate sont nécessaires pour utiliser l'appareil photo

extension ImagePickerController: UIImagePickerControllerDelegate {
    
    // Récupération de l'image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            missionImageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}


extension ImagePickerController: UINavigationControllerDelegate{
    
}
