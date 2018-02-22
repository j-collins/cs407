//
//  AmenitiesViewController.swift
//  cs407
//
//  Created by Johanna Collins on 2/21/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit

class AmenitiesViewController: UIViewController {

    
    
    //MARK: Properties
    var name : String? = "Default"
    //var photo : UIImage?
    
    @IBOutlet weak var buildingNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildingNameLabel.text = name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
