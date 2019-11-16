//
//  Mission.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/30/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import Foundation

class Mission {
    
    // MARK: Attributs
    let id: String
    let titre: String
    let description: String
    let lieu: String
    let debut: Date
    let fin: Date
    let latitude: Double
    let longitude: Double
    let rayon: Double
    var reportText: String?
    var reportImagePath: String?
    var reportDate: Date?
    
    init(id: String, titre: String, lieu: String, description: String, debut: Date, fin: Date, latitude: Double, longitude: Double, rayon: Double) {
        self.id = id
        self.titre = titre
        self.lieu = lieu
        self.description = description
        self.debut = debut
        self.fin = fin
        self.latitude = latitude
        self.longitude = longitude
        self.rayon = rayon
    }
    
    public func setReportText(text:String){
        self.reportText = text
    }
    
    public func setreportImagePath(path:String){
        self.reportImagePath = path
    }
    
    public func setreportDate(date:Date){
        self.reportDate = date
    }
    
}
