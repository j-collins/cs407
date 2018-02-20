//
//  SignUpViewController.swift
//  cs407
//
//  Created by piyushi jaiswal on 2/18/18.
//  Copyright © 2018 CS407Group. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
        //Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //nameTextField.text = nil
    
    //Sign Up Action for email
  /*  @IBAction func createAccountAction(_ sender: AnyObject) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        if emailTextField.text == "" || nameTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your name, email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error == nil {
                    //self.emailTextField.text
                    ref.child("users").child((user?.uid)!).setValue("hellouser");
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    //Auth.auth().currentUser?.sendEmailVerification { (error) in
                        // ...
                  //  }
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        )}} */
    @IBAction func createAccountAction(_ sender: AnyObject) {
        guard let email = emailTextField.text, !email.isEmpty else {print("Email is empty"); return}
         guard let password = passwordTextField.text, !password.isEmpty else {print("Password is empty"); return}
        let ref = Database.database().reference().root
        if email != "" && password != ""{
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                if error == nil {
                    ref.child("users").child((user?.uid)!).setValue(email)
                    print("You have successfully signed up")
                    let user = Auth.auth().currentUser
                    user?.sendEmailVerification(completion: nil)
                    let alert = UIAlertController(title: "Sign Up Success!", message: "Please verify your email by clicking on the link in your inbox", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                        let viewControllerYouWantToPresent = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                        self.present(viewControllerYouWantToPresent!, animated: true, completion: nil)
                    }
                   alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
}

