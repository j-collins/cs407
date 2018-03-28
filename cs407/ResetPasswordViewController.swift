//
//  ResetPasswordViewController.swift
//  cs407
//
//  Created by piyushi jaiswal on 3/27/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation


class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBAction func RestPasswordAction(_ sender: Any) {
        let email = emailTextField.text
            if let email = email {
                    Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                            if let error = error {
                                let alertActionOkay = UIAlertAction(title: "Okay", style: .default) 
                                let alertvc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                                alertvc.addAction(alertActionOkay)
                                alertvc.addAction(alertActionCancel)
                                self.present(alertvc, animated: true, completion: nil)
                               // self.showMessagePrompt(error.localizedDescription)
                                return
                            }
                       let alertac = UIAlertController(title: "Success!", message: "Password reset link is sent to your email", preferredStyle: .alert)
                        let alertActionOkay = UIAlertAction(title: "Okay", style: .default)
                        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                        alertac.addAction(alertActionOkay)
                        alertac.addAction(alertActionCancel)
                        self.present(alertac, animated: true, completion: nil)
                            //self.showMessagePrompt("Sent")
                        
                        }
            }
    }
    //Auth.auth().sendPasswordReset(withEmail: "email@email") { error in
    // Your code here

}
