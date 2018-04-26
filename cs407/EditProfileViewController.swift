//
//  EditProfileViewController.swift
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

class EditProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    var firebasereference : DatabaseReference!
    @IBOutlet weak var NameTextField: UITextField!
   
    @IBAction func ActLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(vc!, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func ActUpdateName(_ sender: Any) {
         let username = NameTextField.text
        if username == ""{
                    let alertController = UIAlertController(title: "Error", message: "Please enter your preferred name in the textfield", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
        if username != ""{
            let user = Auth.auth().currentUser
            let ref = Database.database().reference().root
            ref.child("UserName").child((user?.uid)!).setValue(username)
            let alert = UIAlertController(title: "Edit Success!", message: "Your name is successfully updated!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                //let viewControllerYouWantToPresent = self.storyboard?.instantiateViewController(withIdentifier: "Profile")
                //self.present(viewControllerYouWantToPresent!, animated: true, completion: nil)
                
                //https://stackoverflow.com/questions/28760541/programmatically-go-back-to-previous-viewcontroller-in-swift
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}
    
    


