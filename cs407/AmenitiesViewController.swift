//
//  AmenitiesViewController.swift
//  cs407
//
//  Created by Johanna Collins on 2/21/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AmenitiesViewController: UIViewController {

    
    
    //MARK: Properties
    var name : String? = "Default"
    //var photo : UIImage?
    
    var firebaseReference : DatabaseReference!
    
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var amenitiesTextView: UITextView!
    
    @IBAction func LogOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Define reference variable for firebase database.
        self.firebaseReference = Database.database().reference()

        buildingNameLabel.text = name
        self.firebaseReference?.child("Buildings").child(name!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let actualValue = value {
                self.amenitiesTextView.text = actualValue["Information"] as! String
                
            }
        })
        
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
