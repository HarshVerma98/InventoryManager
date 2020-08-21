//
//  SignupVC.swift
//  InventoryAppBeta1
//
//  Created by Harsh Verma on 22/05/20.
//  Copyright © 2020 Harsh Verma. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class SignupVC: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var errorLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupElements()
    }
    
    func setupElements() {
        errorLbl.alpha = 0
    }
    
    func validateF() -> String? {
        
        if firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please Fill in "
        }
        
        let cleanP = passwordTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Helper.isPasswordValid(cleanP) == false {
            return "Password must be atleast 8 characters long"
        }
        return nil
        
    }
    
    
    @IBAction func signUpBtn(_ sender: Any) {
        
        let error = validateF()
        if error != nil {
            emailTxt.text = error!
            errorLbl.alpha = 1
        }
        
        else {
            let fN = firstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lN = lastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let eM = emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let pWS = passwordTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().createUser(withEmail: eM, password: pWS) { (result, err) in
        
                if err != nil {
                    print("err?.localizedDescription")
                } else {
                    
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["firstname": fN, "lastname": lN, "uid": result?.user.uid]) { (error) in
                        if error != nil {
                            print("error")
                        }
                    }
                    
                    self.transfer()
                }
                
            }
        }
    }
    
    func transfer() {
        let X = storyboard?.instantiateViewController(identifier: HVC) as? GetStarted
        view.window?.rootViewController = X
        view.window?.makeKeyAndVisible()
    }
}
