//
//  Utilisateur.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/30/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import Foundation

class Utilisateur {
    
    // MARK: Attributs
    let nom: String
    let prenom: String
    let entreprise : String
    let isLeader : Bool

    init(nom: String, prenom: String, entreprise: String) {
        self.nom = nom
        self.prenom = prenom
        self.entreprise = entreprise
        self.isLeader = false
    }
    
}
