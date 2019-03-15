//
//  OurTeamViewController.swift
//  Weather.io
//
//  Created by Aaron on 2/12/15.
//  Copyright © 2019 Team 35. All rights reserved.
//

import UIKit

class OurTeamViewController: UIViewController {
    
    @IBAction func BackFromTeam(_ sender: Any) {
        self.performSegue(withIdentifier: "BackFromTeam", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
}
