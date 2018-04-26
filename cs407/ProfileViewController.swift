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
    
  let ref = Database.database().reference().root
  let userid = Auth.auth().currentUser
   
    //LabelEmail.text = user
    //viewDidLoad was not called after popping back from EditProfile. viewWillAppear is called each time.
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        self.LabelEmail.text = user;
        self.LabelPassword.text = "********"
        let userID = Auth.auth().currentUser?.uid
        ref.child("UserName").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? String
            self.LabelName.text = value
           // let username = value?["username"] as? String ?? ""
            //let user = User(username: username)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
         //ref?.child("UserName").child((userid?.uid)!).child
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
