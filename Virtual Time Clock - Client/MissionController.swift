//
//  MissionController.swift
//  Virtual Time Clock - Client
//
//  Created by Emmanuel Nativel on 10/31/19.
//  Copyright © 2019 Emmanuel Nativel. All rights reserved.
//

import UIKit

class MissionController: UIViewController {
    
    var mission: Mission? = nil // La mission courante

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" ✅ Ouverture de la mission \(mission?.titre ?? "INCONNUE" )")

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
