//
//  LoginController.swift
//  chatApp
//
//  Created by Anton Starykov on 8/23/16.
//  Copyright © 2016 thestaryaprod. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //loginButton.setTitle(loginMethodSwitcher.titleForSegmentAtIndex(loginMethodSwitcher.selectedSegmentIndex), forState: .Normal)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //Outlets here
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginMethodSwitcher: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailFieldTopConstraint: NSLayoutConstraint!
              weak var userField: UITextField?
    
    @IBAction func loginHandler(sender: AnyObject) {
        //print(emailField.text, passwordField.text, passwordField.text, userField!.text)

        guard let email = emailField.text, password = passwordField.text
            else {
                print ("Form is not vaild")
                return
        }
        
        func signIn() {
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user: FIRUser?, err) in
                if err != nil {
                    print("Signin in failed")
                    return
                }
                let tableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("chatList")
                self.navigationController?.pushViewController(tableViewController!, animated: true)
            })
        
        }
        
        func signUp() {
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
                if error != nil {
                    print(error)
                    return
                }
                
                //success auth
                let name = (self.userField!.text == nil) ? "" : self.userField!.text
                guard let uid = user?.uid else {
                    return
                }
                let ref = FIRDatabase.database().reference()
                let usersRefference = ref.child("users").child(uid)
                let values = ["name": name!, "email": email]
                usersRefference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print("Database update failed")
                        return
                    }
                    
                    signIn()
                })
            })
        }
        
        switch  loginMethodSwitcher.selectedSegmentIndex {
        case 0:
            signIn()
        case 1:
            signUp()
        default:
            break
        }
        
    }

    @IBAction func loginMethodSwithcerHandler(sender: AnyObject) {
        userField = {
            let userName = UITextField()
                userName.translatesAutoresizingMaskIntoConstraints = false
                userName.placeholder = "username"
                userName.leftView = UIView(frame:CGRectMake(0, 0, 5, 0))
                userName.leftViewMode = UITextFieldViewMode.Always
                userName.backgroundColor = UIColor.whiteColor()
                userName.font = UIFont.systemFontOfSize(15)
                userName.layer.cornerRadius = 5.0
                userName.tag = 0100
            return userName
        }()
        
        switch loginMethodSwitcher.selectedSegmentIndex {
        case 0:
            print("")
            loginButton.setTitle(loginMethodSwitcher.titleForSegmentAtIndex(loginMethodSwitcher.selectedSegmentIndex), forState: .Normal)
            emailFieldTopConstraint.constant = 15
            view.viewWithTag(0100)?.removeFromSuperview()
        case 1:
            emailFieldTopConstraint.constant = 60
            loginButton.setTitle(loginMethodSwitcher.titleForSegmentAtIndex(loginMethodSwitcher.selectedSegmentIndex), forState: .Normal)
            view.addSubview(userField!)
            setupUsernameField(userField!)
        default:
            break
        }
    }
    
    func setupUsernameField(field: UITextField) {
        
        field.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        field.topAnchor.constraintEqualToAnchor(loginMethodSwitcher.bottomAnchor, constant: 15).active = true
        field.widthAnchor.constraintEqualToAnchor(passwordField.widthAnchor).active = true
        field.heightAnchor.constraintEqualToAnchor(passwordField.heightAnchor).active = true
        
        
    }
}
