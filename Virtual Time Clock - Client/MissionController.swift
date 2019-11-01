//
//  MissionController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/31/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit

class MissionController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var missionImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lieuLabel: UILabel!
    @IBOutlet weak var pointerImage: UIImageView!
    @IBOutlet weak var pointerButton: UIButton!
    
    
    var mission: Mission? = nil // La mission courante

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" ✅ Ouverture de la mission \(mission?.titre ?? "INCONNUE" )")
        
        titleLabel.text = mission?.titre
        descriptionLabel.text = mission?.description
        lieuLabel.text = mission?.lieu
        
        setupImages()
        setupButton()

    }
    
    // MARK: Private functions
    
    private func setupImages(){
        // Background de l'entête
        missionImage.layer.backgroundColor = UIColor.white.withAlphaComponent(0.4).cgColor
        missionImage.layer.borderWidth = 2
        missionImage.layer.borderColor = UIColor.white.cgColor
        missionImage.layer.cornerRadius = 45
        missionImage.clipsToBounds = true
        
        //Image de pointage
        //pointerImage.layer.backgroundColor = UIColor.white.withAlphaComponent(0.4).cgColor
        pointerImage.layer.borderWidth = 2
        pointerImage.layer.borderColor = UIColor.black.cgColor
        pointerImage.layer.cornerRadius = 45
        pointerImage.clipsToBounds = true
    }
    
    private func setupButton(){
        // On arrondi le bouton pour qu'il ai la même forme que l'image
        pointerButton.layer.cornerRadius = 45
        // On cache son image
        pointerButton.alpha = 0.1
        pointerButton.tintColor = UIColor.blue
    }
    
    private func checkButton(){
        // Couleur de l'image
        pointerButton.tintColor = UIColor.green
        
        // Fade In : On affiche l'image
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.pointerButton.alpha = 0.8
        }, completion: nil)
        
        // Fade Out : On recache l'image
        UIView.animate(withDuration: 0.1, delay: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.pointerButton.alpha = 0.1
            self.pointerButton.tintColor = UIColor.blue
        }, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func onClickPointerButton(_ sender: UIButton) {
        checkButton()
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
