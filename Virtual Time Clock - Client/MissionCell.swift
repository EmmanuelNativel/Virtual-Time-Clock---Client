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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Fonction qui va extraire les informations nécessaires dans une instance de Mission donnée en paramètre
    func populate(mission: Mission) {
        titreLabel.text = mission.titre
        descriptionLabel.text = mission.description
        lieuLabel.text = mission.lieu
    }

}
