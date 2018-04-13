//
//  ProfileViewController.swift
//  cs407
//
//  Created by piyushi jaiswal on 4/12/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
    @IBOutlet weak var LabelEmail: UILabel!
    @IBOutlet var LabelPassword: UILabel!
    @IBOutlet var LabelName: UILabel!
    let user = Auth.auth().currentUser?.email
    //LabelEmail.text = user
    override func viewDidLoad() {
        super.viewDidLoad()
        self.LabelEmail.text = user;
        self.LabelPassword.text = "********"
    }
 
    @IBAction func LogoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
}
