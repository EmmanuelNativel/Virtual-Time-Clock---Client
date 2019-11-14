//
//  MissionCell.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/30/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit

class MissionCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var titreLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lieuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Fonction qui va extraire les informations nécessaires dans une instance de Mission donnée en paramètre
    func populate(mission: Mission) {
        titreLabel.text = mission.titre
        descriptionLabel.text = mission.description
        lieuLabel.text = mission.lieu
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Changement des marges des cellules, de la bordure et du fond
        let padding = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        contentView.frame = contentView.frame.inset(by: padding)
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.addGradientBackground(firstColor: UIColor(named: "orangeFonce")!, secondColor: UIColor(named: "orangeClair")!)
    }
    

}

// Extension de UIView permettant de rajouter un fond dégradé de 2 couleurs
extension UIView{
    func addGradientBackground(firstColor: UIColor, secondColor: UIColor){
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
