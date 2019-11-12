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
        
        //Changement de la couleur de fond
        backgroundColor = UIColor(named: "grisFonce")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //Couleur dans l'état sélectionné
        backgroundColor = UIColor(named: "orangeFonce")
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
        let padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        contentView.frame = contentView.frame.inset(by: padding)
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.backgroundColor = UIColor(named: "orangeClair")?.cgColor
    }
    

}
