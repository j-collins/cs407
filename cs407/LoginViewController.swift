//
//  LoginViewController.swift
//  cs407
//
//  Created by piyushi jaiswal on 2/18/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    //Login Action    
    @IBAction func loginAction(_ sender: AnyObject) {
    guard let email = emailTextField.text, let password = passwordTextField.text else {return}
    Auth.auth().signIn(withEmail: email, password: password){ (user,error) in
    if let error = error {
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
    if let user = Auth.auth().currentUser {
    if !user.isEmailVerified{
        let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(email)?", preferredStyle: .alert)
        let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
    (_) in
            user.sendEmailVerification(completion: nil)
    }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    
    alertVC.addAction(alertActionOkay)
    alertVC.addAction(alertActionCancel)
        self.present(alertVC, animated: true, completion: nil)
    } else {
    print ("Email verified. Signing in...")
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
    self.present(vc!, animated: true, completion: nil)
    }
    }
    }
    }
    
    /* Method to hide keyboard if the user taps outside of the keyboard */
    @IBAction func tapAnywhereToRemoveKeyboard(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}


