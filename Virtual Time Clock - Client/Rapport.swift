//
//  Rapport.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 11/4/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import Foundation

class Rapport {
    
    var texte: String
    var imagePath: String
    var date:Date
    
    init(texte:String, imagePath: String, date:Date) {
        self.texte = texte
        self.imagePath = imagePath
        self.date = date
    }
    
    init(){
        self.texte = ""
        self.imagePath = ""
        self.date = Date()
    }
    
    public func getDateFormat() -> String {
        return DateFormatter.localizedString(from: self.date, dateStyle: .medium, timeStyle: .short)
    }
    
}
